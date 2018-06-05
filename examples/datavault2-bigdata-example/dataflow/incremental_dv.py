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


CONST_LOADDTM_FIELD = 'dv__load_dtm'
CONST_CKSUM_FIELD = '__row_cksum'
CONST_SOURCE_FIELD = 'dv__rec_source'
CONST_BK_FIELD = 'dv__bk'
LINK_KEY = 'dv__link_key'
CONST_STATUS_FIELD = 'dv__status'


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


def get_business_key(record, bkey_list):
    s = ''
    first = True
    for key in bkey_list:
        if not first:
            s += '|'
        val = record.get(key, '')
        s += str(val).strip().upper()
        first = False
    return s


def calc_cksum(record):
    m = hashlib.md5()
    c = {k:v for k, v in record.items() if k != CONST_LOADDTM_FIELD and k != CONST_STATUS_FIELD}
    m.update(repr(sorted(c.items())))
    return m.hexdigest().upper()


def add_hub_dv_details(record, bkey_list, source):
    rec = record[1]
    rec[CONST_CKSUM_FIELD] = calc_cksum(rec)
    rec[CONST_SOURCE_FIELD] = source
    bk = get_business_key(rec, bkey_list)
    m = hashlib.md5()
    m.update(bk)
    rec[CONST_BK_FIELD] = m.hexdigest().upper()
    return (record[0], rec)


def add_link_dv_details(record, pk_keys, source):
    pk = [record.get(key[1], '') for key in pk_keys]
    pk = '|'.join(pk)
    record[LINK_KEY] = pk
    record[CONST_SOURCE_FIELD] = source
    record[CONST_CKSUM_FIELD] = calc_cksum(record)
    return (pk, record)


def hub_select_index_or_data(record, pk):
    index = record[1]['index']
    data = record[1]['data']
    if len(data) == 1:
        data_rec = data[0]
        return {CONST_BK_FIELD: data_rec[CONST_BK_FIELD],
                CONST_CKSUM_FIELD: data_rec[CONST_CKSUM_FIELD],
                pk: data_rec[pk]}

    if len(index) == 1 and len(data) == 0:
        index_rec = index[0]
        return {CONST_BK_FIELD: index_rec[CONST_BK_FIELD],
                CONST_CKSUM_FIELD: index_rec[CONST_CKSUM_FIELD],
                pk: index_rec[pk]}
    raise Exception("No valid record found")


def link_select_index_or_data(record, pk):
    index = record[1]['index']
    data = record[1]['data']
    if len(data) == 1:
        data_rec = data[0]
        return {CONST_CKSUM_FIELD: data_rec[CONST_CKSUM_FIELD],
                pk: data_rec[pk]}

    if len(index) == 1 and len(data) == 0:
        index_rec = index[0]
        return {CONST_CKSUM_FIELD: index_rec[CONST_CKSUM_FIELD],
                pk: index_rec[pk]}

    raise Exception("No valid record found")


def filter_data_rows(record):
    index = record[1]['index']
    data = record[1]['data']
    if len(index) > 1 or len(data) > 1:
        raise Exception("Primary key is not unique")

    if len(data) == 1:
        # always pick up new rows
        return True

    # all other cases, filter out the row
    return False

def extract_data(record):
    index = record[1]['index']
    data = record[1]['data']
    if len(index) > 1 or len(data) > 1:
        raise Exception("Primary key is not unique")

    return data[0]


def apply_business_key(record, field_name):
    index = record[1]['index']
    data = record[1]['data']
    for rec in data:
        if len(index) > 0:
            bk = index[0][CONST_BK_FIELD]
            rec[field_name] = bk
        else:
            rec[field_name] = None
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
        self.loading = os.path.join(known_args.root, 'loading', self.source)

    def get_psa(self, loc):
        return os.path.join(self.psa, loc)

    def get_psa_incremental(self, loc):
        return os.path.join(self.psa, loc, self.year, self.month, self.day, loc)

    def get_psa_location(self, loc):
        return os.path.join(self.psa, loc, self.year, self.month, self.day, loc)

    def get_loading_location(self, loc):
        return os.path.join(self.loading, loc, self.year, self.month, self.day, loc)

    def get_index(self, loc):
        return os.path.join(self.index, loc)

    def get_staging(self, loc):
        return os.path.join(self.staging, loc)

    def get_staging_location(self, key):
        return os.path.join(self.staging, key, self.year, self.month, self.day, key)

    def resolve_foreign_keys(self, hub_name, pk, data, foreign_keys, pipeline):
        data = data | 'Unkey_{0}'.format(hub_name) >> \
            beam.Map(lambda x: x[1])

        # Resolve foreign keys first
        for fk in foreign_keys:
            fk_table = fk[0]
            fk_key = fk[1]

            fk_index = None
            try:
                # Also set up a stream for the index
                fk_index = read_file(
                    pipeline,
                    '{0}index'.format(fk_table),
                    self.get_index('hub_{0}*'.format(fk_table)),
                    fk_key)
            except IOError:
                logging.info("Could not open index, maybe doesn't exist")
                # create an empty pcollection, so we can at least run
                fk_index = p | beam.Create([])

            data = data | 'Rekey_{0}_{1}'.format(hub_name, fk_table) >> \
                beam.Map(lambda x: (x[fk_key], x))
            merge = ({'data': data, 'index': fk_index}) | \
                'resolve_{0}_{1}'.format(hub_name, fk_table) >> \
                beam.CoGroupByKey()
            # merge | 'print_{0}'.format(fk_table) >> beam.Map(print_index)
            data = merge | 'convert_{0}_{1}'.format(hub_name, fk_table) >> \
                beam.FlatMap(apply_business_key, '{0}_bk'.format(fk_table))
        data = data | 'Rekey_{0}'.format(hub_name) >> \
            beam.Map(lambda x: (x[pk], x))

        return data

    def run(self):
        self.pipeline_options = PipelineOptions(self.pipeline_args)
        self.pipeline_options.view_as(SetupOptions).save_main_session = True

        # We consider the city a reference table and the design decision here
        # is that the address table will contain city+country into the satellite,
        # ditching the over normalization. This is much easier to do in hive later on
        # by joining on the id's in staging.
        self.process_hub(
            hub_name='address',
            pk='address_id',
            bkey_list=['postal_code', 'address'],
            field_list=['address', 'address2', 'district', 'city_id',
            'postal_code', 'phone', 'last_update'])
        self.process_hub(
            hub_name='customer',
            pk='customer_id',
            bkey_list=['email'],
            field_list=['first_name', 'last_name', 'email', 'activebool',
            'create_date', 'last_update', 'active', 'address_bk'],
            foreign_keys=[('address', 'address_id')])

        # Store/staff have bi-directional references, so we have to resolve the manager
        # link later on.
        self.process_hub(
            hub_name='store',
            pk='store_id',
            bkey_list=['store_id'],
            field_list=['last_update', 'manager_staff_id', 'address_bk'],
            foreign_keys=[('address', 'address_id')])
        self.process_hub(
            hub_name='staff',
            pk='staff_id',
            bkey_list=['first_name', 'last_name'],
            field_list=['staff_id', 'first_name' ,'last_name', 'address_bk', 'email', 'store_bk', 'active',
            'username', 'password', 'last_update'],
            foreign_keys=[('address', 'address_id'), ('store', 'store_id')])
        self.process_hub(
            hub_name='city',
            pk='city_id',
            bkey_list=['city'],
            field_list=['city_id', 'city', 'country_id', 'last_update'])
        self.process_hub(
            hub_name='country',
            pk='country_id',
            bkey_list=['country_id'],
            field_list=['country_id', 'country', 'last_update'])

        self.process_hub(
            hub_name='actor',
            pk='actor_id',
            bkey_list=['first_name', 'last_name'],
            field_list=['first_name', 'last_name', 'last_update'])

        self.process_hub(
            hub_name='language',
            pk='language_id',
            bkey_list=['name'],
            field_list=['name', 'last_update'])
        self.process_hub(
            hub_name='category',
            pk='category_id',
            bkey_list=['name'],
            field_list=['name', 'last_update'])
        self.process_hub(
            hub_name='film',
            pk='film_id',
            bkey_list=['title', 'release_year'],
            field_list=['title', 'description', 'release_year', 'rental_duration', 'rental_rate',
            'length', 'replacement_cost', 'rating', 'last_update', 'special_features', 'fulltext', 'language_bk'],
            foreign_keys=[('language', 'language_id')])

        # We process inventory as if it were a hub table, because we need the inventory_bk
        self.process_hub(
            hub_name='inventory',
            pk='inventory_id',
            bkey_list=['inventory_id'],
            field_list=['film_id', 'store_id', 'last_update'],
            foreign_keys=[('film', 'film_id'), ('store', 'store_id')])

        # Rental could be a hub, could be a link.
        # We process it as a hub for that reason, because it can be converted
        # to any type later on (or produce multiple links)
        self.process_hub(
            hub_name='rental',
            pk='rental_id',
            bkey_list=['rental_id'],
            field_list=['rental_date', 'return_date', 'last_update', 'inventory_bk', 'customer_bk'],
            foreign_keys=[('inventory', 'inventory_id'), ('customer', 'customer_id')])
        self.process_hub(
            hub_name='payment',
            pk='payment_id',
            bkey_list=['payment_id'],
            field_list=['payment_date', 'amount', 'customer_bk', 'staff_bk', 'rental_bk'],
            foreign_keys=[('customer', 'customer_id'), ('staff', 'staff_id'), ('rental', 'rental_id')])

        # Links follow a different processing:
        self.process_link(
            link_name='film_category',
            foreign_keys=[('film', 'film_id'), ('category', 'category_id')],
            field_list=['film_bk', 'category_bk'],
            bkey_list=['film_bk', 'category_bk'])
        self.process_link(
            link_name='film_actor',
            foreign_keys=[('film', 'film_id'), ('actor', 'actor_id')],
            field_list=['film_bk', 'actor_bk'],
            bkey_list=['film_bk', 'actor_bk'])

    def process_hub(self,
                    hub_name,
                    pk,
                    bkey_list,
                    field_list,
                    foreign_keys=None):
        ext_field_list = \
            field_list + [CONST_BK_FIELD, CONST_SOURCE_FIELD, CONST_LOADDTM_FIELD, CONST_STATUS_FIELD]

        with beam.Pipeline(options=self.pipeline_options) as p:
            # First set up a stream for the data
            data = read_file(
                p,
                hub_name,
                self.get_psa_location('public.{0}'.format(hub_name)) + '*',
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
                beam.Map(add_hub_dv_details, bkey_list, self.source)

            if foreign_keys:
                data = self.resolve_foreign_keys(
                    hub_name=hub_name,
                    pk=pk,
                    data=data,
                    foreign_keys=foreign_keys,
                    pipeline=p)

            # Group with index to be able to identify new, updated, deleted
            merge = ({'data': preproc_data, 'index': index}) | 'grouped_by_' + pk >> beam.CoGroupByKey()

            # Extract the data out of the records (still has index/data dict in there)
            extract = merge \
                | 'filter_' + hub_name >> beam.Filter(filter_data_rows) \
                | 'extract_' + hub_name >> beam.Map(extract_data)

            # Write them out to disk in loading area
            extract | 'Write_' + hub_name >> beam.io.Write(
                CsvFileSink(
                    self.get_loading_location('public.{0}'.format(hub_name)),
                    header=ext_field_list))

            # Update the index
            updated_index = merge | 'updated_index_' + hub_name >> beam.Map(hub_select_index_or_data, pk)
            updated_index | 'Write_index_' + hub_name >> beam.io.Write(
                CsvFileSink(
                    self.get_index('hub_{0}'.format(hub_name)),
                    header=[CONST_BK_FIELD, CONST_CKSUM_FIELD, pk]))

    def process_link(self,
                     link_name,
                     bkey_list,
                     field_list,
                     foreign_keys):
        ext_field_list = \
            [CONST_BK_FIELD, CONST_SOURCE_FIELD, CONST_LOADDTM_FIELD, CONST_STATUS_FIELD] + \
            field_list

        keys = [t[1] for t in foreign_keys]
        generated_pk_name = '|'.join(keys)

        with beam.Pipeline(options=self.pipeline_options) as p:
            data = read_file(
                p,
                link_name,
                self.get_psa_location('public.{0}'.format(link_name)) + '*')

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

            preproc_data = data | 'preprocess_' + link_name >> \
                beam.Map(add_link_dv_details, foreign_keys, self.source)

            preproc_data = self.resolve_foreign_keys(
                hub_name=link_name,
                pk=LINK_KEY,
                data=preproc_data,
                foreign_keys=foreign_keys,
                pipeline=p)

            # Group with index to be able to identify new, updated, deleted
            merge = ({'data': preproc_data, 'index': index}) | 'grouped_by_' + generated_pk_name >> beam.CoGroupByKey()

            # Extract the data out of the records (still has index/data dict in there)
            extract = merge \
                | 'filter_' + link_name >> beam.Filter(filter_data_rows) \
                | 'extract_' + link_name >> beam.Map(extract_data)

            # Write them out to disk in staging
            extract | 'Write_' + link_name >> beam.io.Write(
                CsvFileSink(
                    self.get_loading_location('public.{0}'.format(link_name)),
                    header=ext_field_list))

            # Update the index
            updated_index = merge | 'updated_index_' + link_name >> beam.Map(link_select_index_or_data, LINK_KEY)
            updated_index | 'Write_index_' + link_name >> beam.io.Write(
                CsvFileSink(
                    self.get_index('link_{0}'.format(link_name)),
                    header=[CONST_CKSUM_FIELD, LINK_KEY]))


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    p = DvdRentalsPipeline('dvdrentals')
    p.parse(sys.argv)
    p.run()
