import argparse
from datetime import datetime
import hashlib
import logging
import os
import sys

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions

from utils.filesource import CsvFileSource
from utils.filesink import CsvFileSink


CONST_CKSUM_FIELD = '__row_cksum'
CONST_BK_FIELD = 'dv__bk'
CONST_SOURCE_FIELD = 'dv__rec_source'
CONST_LOADDTM_FIELD = 'dv__load_dtm'
CONST_STATUS_FIELD = 'dv__status'
LINK_KEY = 'dv__link_key'


def print_line(record):
    print(record)


def print_index(record):
    # index = record[1]['index']
    # data = record[1]['data']
    print(record)
    # print(record[0], len(index), len(data))


# Helper: read a tab-separated key-value mapping from a text file,
# escape all quotes/backslashes, and convert it a PCollection of
# (key, record) pairs.
def read_file(p, label, file_pattern, pk=None):
    data = p | 'Read: %s' % label >> beam.io.Read(CsvFileSource(file_pattern,
                                                                add_source=False,
                                                                dictionary_output=True))
    if pk:
        data = data | 'Key: %s' % label >> beam.Map(lambda x: (x[pk], x))
    return data


def calc_cksum(record):
    m = hashlib.md5()
    c = {k:v for k, v in record.items() if k != CONST_LOADDTM_FIELD and k != CONST_STATUS_FIELD}
    m.update(repr(sorted(c.items())))
    return m.hexdigest().upper()


def add_cksum(record):
    rec = record[1]
    rec[CONST_CKSUM_FIELD] = calc_cksum(rec)
    return (record[0], rec)


def add_link_cksum(record, pk_keys):
    pk = [record.get(key, '') for key in pk_keys]
    pk = '|'.join(pk)
    record[CONST_CKSUM_FIELD] = calc_cksum(record)
    return (pk, record)


def filter_unchanged_rows(record):
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

        parsed_dtm = datetime.strptime(known_args.execution_dtm, '%Y-%m-%dT%H:%M:%S')
        self.parsed_dtm = parsed_dtm
        self.year = str(parsed_dtm.year)
        self.month = '{0:02d}'.format(parsed_dtm.month)
        self.day = '{0:02d}'.format(parsed_dtm.day)
        self.psa = os.path.join(known_args.root, 'psa', self.source)
        self.index = os.path.join(known_args.root, 'index', self.source)
        self.staging = os.path.join(known_args.root, 'staging', self.source)

    def get_psa(self, loc):
        return os.path.join(self.psa, loc)

    def get_psa_incremental(self, loc):
        return os.path.join(self.psa, loc, self.year, self.month, self.day, loc)

    def get_psa_location(self, loc):
        return os.path.join(self.psa, loc, self.year, self.month, self.day, loc)

    def get_index(self, loc):
        return os.path.join(self.index, loc)

    def get_staging(self, loc):
        return os.path.join(self.staging, loc)

    def get_staging_location(self, key):
        return os.path.join(self.staging, key, self.year, self.month, self.day, key)

    def run(self):
        self.pipeline_options = PipelineOptions(self.pipeline_args)
        self.pipeline_options.view_as(SetupOptions).save_main_session = True

        self.process_table(
            hub_name='address',
            pk='address_id',
            field_list=['address_id', 'address', 'address2', 'district', 'city_id',
            'postal_code', 'phone', 'last_update'])
        self.process_table(
            hub_name='customer',
            pk='customer_id',
            field_list=['customer_id', 'store_id', 'first_name', 'last_name', 'email', 'address_id', 
            'activebool', 'create_date', 'last_update', 'active'])
        self.process_table(
            hub_name='store',
            pk='store_id',
            field_list=['store_id', 'manager_staff_id', 'address_id', 'last_update'])
        self.process_table(
            hub_name='staff',
            pk='staff_id',
            field_list=['staff_id', 'first_name' ,'last_name', 'address_id', 'email', 'store_id', 'active',
            'last_update'])
        self.process_table(
            hub_name='city',
            pk='city_id',
            field_list=['city_id', 'city', 'country_id', 'last_update'])
        self.process_table(
            hub_name='country',
            pk='country_id',
            field_list=['country_id', 'country', 'last_update'])
        self.process_table(
            hub_name='actor',
            pk='actor_id',
            field_list=['actor_id', 'first_name', 'last_name', 'last_update'])
        self.process_table(
            hub_name='language',
            pk='language_id',
            field_list=['language_id', 'name', 'last_update'])
        self.process_table(
            hub_name='category',
            pk='category_id',
            field_list=['category_id', 'name', 'last_update'])
        self.process_table(
            hub_name='film',
            pk='film_id',
            field_list=['film_id', 'title', 'description', 'release_year', 'language_id', 'rental_duration', 'rental_rate',
            'length', 'replacement_cost', 'rating', 'last_update', 'special_features', 'fulltext'])
        self.process_table(
            hub_name='inventory',
            pk='inventory_id',
            field_list=['inventory_id', 'film_id', 'store_id', 'last_update'])
        self.process_table(
            hub_name='rental',
            pk='rental_id',
            field_list=['rental_id', 'rental_date', 'inventory_id', 'customer_id', 'return_date', 
            'staff_id', 'last_update'])
        self.process_link(
            link_name='film_category',
            field_list=['film_id', 'category_id', 'last_update'],
            foreign_keys=['film_id', 'category_id'])
        self.process_link(
            link_name='film_actor',
            field_list=['film_id', 'actor_id', 'last_update'],
            foreign_keys=['film_id', 'actor_id'])

    def process_table(self,
                    hub_name,
                    pk,
                    field_list):
        ext_field_list = \
            field_list + [CONST_LOADDTM_FIELD, CONST_STATUS_FIELD]

        with beam.Pipeline(options=self.pipeline_options) as p:
            # First set up a stream for the data
            data = read_file(
                p,
                hub_name,
                self.get_staging_location('public.{0}'.format(hub_name)) + '*',
                pk)

            index = None
            try:
                # Also set up a stream for the index
                index = read_file(
                    p,
                    '{0}index'.format(hub_name),
                    self.get_index('hub_{0}*'.format(hub_name)),
                    pk)
            except IOError:
                logging.info("Could not open index, maybe doesn't exist")
                # create an empty pcollection, so we can at least run
                index = p | beam.Create([])

            # Generate business keys, checksum, dv_source, load_dtm
            preproc_data = data | 'preprocess_' + hub_name >> \
                beam.Map(add_cksum)

            # Group with index to be able to identify new, updated, deleted
            merge = ({'data': preproc_data, 'index': index}) | 'grouped_by_' + pk >> beam.CoGroupByKey()

            # Extract the data out of the records (still has index/data dict in there)
            extract = merge \
                | 'filter_' + hub_name >> beam.Filter(filter_unchanged_rows) \
                | 'extract_' + hub_name >> beam.Map(extract_data)

            # Write them out to disk in staging
            extract | 'Write_' + hub_name >> beam.io.Write(
                CsvFileSink(
                    self.get_psa_location('public.{0}'.format(hub_name)),
                    header=ext_field_list))

    def process_link(self,
                     link_name,
                     field_list,
                     foreign_keys):
        ext_field_list = field_list + [CONST_LOADDTM_FIELD, CONST_STATUS_FIELD]
        generated_pk_name = '|'.join(foreign_keys)

        with beam.Pipeline(options=self.pipeline_options) as p:
            data = read_file(
                p,
                link_name,
                self.get_staging_location('public.{0}'.format(link_name)) + '*')

            preproc_data = data | 'preprocess_' + link_name >> \
                beam.Map(add_link_cksum, foreign_keys)

            index = None
            try:
                # Also set up a stream for the index
                index = read_file(
                    p,
                    '{0}index'.format(link_name),
                    self.get_index('link_{0}*'.format(link_name)),
                    LINK_KEY)
            except IOError:
                logging.info("Could not open index, maybe doesn't exist")
                # create an empty pcollection, so we can at least run
                index = p | beam.Create([])

            # Group with index to be able to identify new, updated, deleted
            merge = ({'data': preproc_data, 'index': index}) | 'grouped_by_' + generated_pk_name >> beam.CoGroupByKey()

            # Extract the data out of the records (still has index/data dict in there)
            extract = merge \
                | 'filter_' + link_name >> beam.Filter(filter_unchanged_rows) \
                | 'extract_' + link_name >> beam.Map(extract_data)

            # Write them out to disk in staging
            extract | 'Write_' + link_name >> beam.io.Write(
                CsvFileSink(
                    self.get_psa_location('public.{0}'.format(link_name)),
                    header=ext_field_list))


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    p = DvdRentalsPipeline('dvdrentals')
    p.parse(sys.argv)
    p.run()
