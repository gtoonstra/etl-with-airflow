import argparse
from datetime import datetime, timedelta
import hashlib
import logging
import os
import sys
import json

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions


CONST_CKSUM_FIELD = 'dv__cksum'
CONST_BK_FIELD = 'dv__bk'
CONST_SOURCE_FIELD = 'dv__rec_source'
CONST_LOADDTM_FIELD = 'dv__load_dtm'
CONST_STATUS_FIELD = 'dv__status'


class JsonCoder(object):
    """A JSON coder interpreting each line as a JSON string."""
    def encode(self, x):
        return json.dumps(x)

    def decode(self, x):
        return json.loads(x)


# Helper: read a tab-separated key-value mapping from a text file,
# and convert it a PCollection of (key, record) pairs.
def read_file(p, label, file_pattern, pk=None):
    data = p | 'Read: {label}'.format(label=label) >> \
        ReadFromText(file_pattern, coder=JsonCoder())

    if pk:
        data = data | 'Key: {label}'.format(label=label) >> \
            beam.Map(lambda x: (x[pk], x))
    return data


def calc_cksum(record):
    m = hashlib.md5()
    c = {k: v for k, v in record.items()
         if k != CONST_LOADDTM_FIELD and k != CONST_STATUS_FIELD and k != CONST_CKSUM_FIELD}
    m.update(repr(sorted(c.items())))
    return m.hexdigest().upper()


def add_cksum(record):
    rec = record[1]
    rec[CONST_CKSUM_FIELD] = calc_cksum(rec)
    return (record[0], rec)


def unchanged_rows(record):
    index = record[1]['index']
    data = record[1]['data']
    if len(index) > 1 or len(data) > 1:
        raise Exception("Primary key is not unique")

    if len(index) == 0 and len(data) == 1:
        # always pick up new rows
        return True

    if len(index) == 1 and len(data) == 1:
        rec_index = index[0]
        rec_data = data[0]
        if rec_index[CONST_CKSUM_FIELD] != rec_data[CONST_CKSUM_FIELD]:
            # also pick up updated rows
            return True

    if len(index) == 1 and len(data) == 0:
        # Pick up deleted rows too.
        return True

    # all other cases, filter out the row
    return False


def extract_data(record):
    index = record[1]['index']
    data = record[1]['data']
    if len(index) > 1 or len(data) > 1:
        raise Exception("Primary key is not unique")

    if len(index) == 0 and len(data) == 1:
        data = data[0]
        data[CONST_STATUS_FIELD] = "NEW"
        return data
    if len(index) == 1 and len(data) == 1:
        data = data[0]
        data[CONST_STATUS_FIELD] = "UPDATED"
        return data
    if len(index) == 1 and len(data) == 0:
        data = data[0]
        data[CONST_STATUS_FIELD] = "DELETED"
        return data

    data = data[0]
    data[CONST_STATUS_FIELD] = "UNKNOWN"
    return data


class DvdRentalsPipeline(object):
    def __init__(self, source, *args, **kwargs):
        self.source = source

    def parse(self, argv):
        parser = argparse.ArgumentParser()
        parser.add_argument('--root',
                            required=True,
                            help=('Where root of processing area is'))
        parser.add_argument('--execution_dtm',
                            required=True,
                            help=('Day for which to execute the data flow'))
        known_args, self.pipeline_args = parser.parse_known_args(argv)
        print(known_args)

        parsed_dtm = datetime.strptime(known_args.execution_dtm,
                                       '%Y-%m-%dT%H:%M:%S')
        self.parsed_dtm = parsed_dtm
        self.year = str(parsed_dtm.year)
        self.month = '{0:02d}'.format(parsed_dtm.month)
        self.day = '{0:02d}'.format(parsed_dtm.day)
        self.yesterday_dtm = parsed_dtm - timedelta(days=1)
        self.psa = os.path.join(known_args.root, 'psa', self.source)
        self.index = os.path.join(known_args.root, 'index', self.source)
        self.staging = os.path.join(known_args.root, 'staging', self.source)

    def get_psa_location(self, loc):
        return os.path.join(self.psa,
                            loc,
                            self.year,
                            self.month,
                            self.day,
                            loc)

    def get_source_index(self, loc):
        return os.path.join(self.index,
                            self.yesterday_dtm.strftime('%Y-%m-%d_') + loc)

    def get_staging(self, key):
        return os.path.join(self.staging,
                            key,
                            self.year,
                            self.month,
                            self.day,
                            key)

    def run(self):
        self.pipeline_options = PipelineOptions(self.pipeline_args)
        self.pipeline_options.view_as(SetupOptions).save_main_session = True

        self.process_entity(
            entity_name='store',
            pk='store_id')
        self.process_entity(
            entity_name='staff',
            pk='staff_id')
        self.process_entity(
            entity_name='film',
            pk='film_id')
        self.process_entity(
            entity_name='inventory',
            pk='inventory_id')

    def process_entity(self, entity_name, pk):
        with beam.Pipeline(options=self.pipeline_options) as p:
            # First set up a stream for the data
            data = read_file(
                p,
                entity_name,
                self.get_staging('public.{0}'.format(entity_name)) + '*',
                pk)

            index = None
            try:
                # Also set up a stream for the index
                index = read_file(
                    p,
                    '{0}index'.format(entity_name),
                    self.get_source_index('entity_{0}*'.format(entity_name)),
                    pk)
            except IOError:
                logging.info("Could not open index, maybe doesn't exist")
                # create an empty pcollection, so we can at least run
                index = p | beam.Create([])

            # Generate business keys, checksum, dv_source, load_dtm
            preproc_data = data | 'preprocess_' + entity_name >> \
                beam.Map(add_cksum)

            # Group with index to be able to identify new, updated, deleted
            merge = ({'data': preproc_data, 'index': index}) | \
                'grouped_by_' + pk >> beam.CoGroupByKey()

            # Extract the modified data out of the records
            extract = merge \
                | 'filter_' + entity_name >> beam.Filter(unchanged_rows) \
                | 'extract_' + entity_name >> beam.Map(extract_data)

            # Write them out to disk in staging
            extract | 'Write_' + entity_name >> \
                WriteToText(
                    self.get_psa_location('public.{0}'.format(entity_name)),
                    coder=JsonCoder())


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    p = DvdRentalsPipeline('dvdrentals')
    p.parse(sys.argv)
    p.run()
