import argparse
from datetime import datetime, timedelta
import hashlib
import logging
import json
import os
import sys

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToAvro
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
import avro


CONST_LOADDTM_FIELD = 'dv__load_dtm'
CONST_CKSUM_FIELD = '__row_cksum'
CONST_SOURCE_FIELD = 'dv__rec_source'
CONST_BK_FIELD = 'dv__bk'
CONST_STATUS_FIELD = 'dv__status'


class JsonCoder(object):
    """A JSON coder interpreting each line as a JSON string."""
    def encode(self, x):
        return json.dumps(x)

    def decode(self, x):
        return json.loads(x)


def print_record(record):
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
    data = p | 'Read: {label}'.format(label=label) >> \
        ReadFromText(file_pattern, coder=JsonCoder())

    if pk:
        data = data | 'Key: {label}'.format(label=label) >> \
            beam.Map(lambda x: (x[pk], x))
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


def add_entity_dv_details(record, bkey_list, source):
    rec = record[1]
    rec[CONST_CKSUM_FIELD] = calc_cksum(rec)
    rec[CONST_SOURCE_FIELD] = source
    bk = get_business_key(rec, bkey_list)
    m = hashlib.md5()
    m.update(bk)
    rec[CONST_BK_FIELD] = m.hexdigest().upper()
    return (record[0], rec)


def entity_select_index_or_data(record, pk):
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


def apply_business_key(record, pk, entity_name, foreign_entity):
    index = record[1]['index']
    data = record[1]['data']
    field_name = '{0}_bk'.format(foreign_entity)
    comb_name = entity_name + "_" + foreign_entity + '_bk'

    for rec in data:
        if len(index) > 0:
            bk = index[0][CONST_BK_FIELD]
            rec[field_name] = bk
            #comb_val = str(rec[pk]).strip().upper() + "|" + bk
            #m = hashlib.md5()
            #m.update(comb_val)
            #rec[comb_name] = m.hexdigest().upper()
        else:
            rec[field_name] = None
    return data


def apply_bk(rec, bkey_list):
    bk = get_business_key(rec, bkey_list)
    m = hashlib.md5()
    m.update(bk)
    rec[CONST_BK_FIELD] = m.hexdigest().upper()    


class AbstractToDataVault2(beam.DoFn):
    def prepare_output(self, rec, parent_rec, bkey_list):
        rec[CONST_LOADDTM_FIELD] = parent_rec[CONST_LOADDTM_FIELD]
        rec[CONST_SOURCE_FIELD] = parent_rec[CONST_SOURCE_FIELD]
        rec[CONST_STATUS_FIELD] = parent_rec[CONST_STATUS_FIELD]
        apply_bk(rec, bkey_list)

    @staticmethod
    def load_avro_schema(root, filename):
        filename = os.path.join(root, filename)
        return avro.schema.parse(open(filename, "rb").read())


class FilmToDataVault2(AbstractToDataVault2):
    """ A transform which creates multiple outputs from the film entity into the desired
    records for the DV 2.0 model
    """

    # These tags will be used to tag the outputs of this DoFn.
    TAG_LANGUAGE = 'language'
    TAG_ACTOR = 'actor'
    TAG_CATEGORY = 'category'
    TAG_FILM_LANGUAGE = 'film_language'
    TAG_FILM_ACTOR = 'film_actor'
    TAG_FILM_CATEGORY = 'film_category'
    HUB_OUTPUTS = [TAG_LANGUAGE, TAG_ACTOR, TAG_CATEGORY]
    LINK_OUTPUTS = [TAG_FILM_LANGUAGE, TAG_FILM_ACTOR, TAG_FILM_CATEGORY]

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            FilmToDataVault2.TAG_LANGUAGE: 'language.avsc',
            FilmToDataVault2.TAG_ACTOR: 'actor.avsc',
            FilmToDataVault2.TAG_CATEGORY: 'category.avsc',
            FilmToDataVault2.TAG_FILM_LANGUAGE: 'film_language.avsc',
            FilmToDataVault2.TAG_FILM_ACTOR: 'film_actor.avsc',
            FilmToDataVault2.TAG_FILM_CATEGORY: 'film_category.avsc',
            'film': 'film.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, film):
        if 'categories' in film and film['categories'] is not None:
            for category in film['categories']:
                self.prepare_output(category, film, ['name'])
                yield beam.pvalue.TaggedOutput(self.TAG_CATEGORY, category)
                film_category = {
                    "film_bk": film[CONST_BK_FIELD],
                    "category_bk": category[CONST_BK_FIELD]
                }
                self.prepare_output(film_category, film, film_category.keys())
                yield beam.pvalue.TaggedOutput(self.TAG_FILM_CATEGORY, film_category)

        if 'languages' in film and film['languages'] is not None:
            for language in film['languages']:
                self.prepare_output(language, film, ['name'])
                yield beam.pvalue.TaggedOutput(self.TAG_LANGUAGE, language)
                film_language = {
                    "film_bk": film[CONST_BK_FIELD],
                    "language_bk": language[CONST_BK_FIELD]
                }
                self.prepare_output(film_language, film, film_language.keys())
                yield beam.pvalue.TaggedOutput(self.TAG_FILM_LANGUAGE, film_language)
        if 'actors' in film and film['actors'] is not None:
            for actor in film['actors']:
                self.prepare_output(actor, film, ['first_name', 'last_name'])
                yield beam.pvalue.TaggedOutput(self.TAG_ACTOR, actor)
                film_actor = {
                    "film_bk": film[CONST_BK_FIELD],
                    "actor_bk": actor[CONST_BK_FIELD]
                }
                self.prepare_output(film_actor, film, film_actor.keys())
                yield beam.pvalue.TaggedOutput(self.TAG_FILM_ACTOR, film_actor)

        del film['categories']
        del film['languages']
        del film['actors']

        film['special_features'] = str(film['special_features'])

        yield film


class StoreToDataVault2(AbstractToDataVault2):
    HUB_OUTPUTS = []
    LINK_OUTPUTS = []

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            'store': 'store.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, store):
        yield store


class StaffToDataVault2(AbstractToDataVault2):
    TAG_STAFF_STORE = 'staff_store'
    HUB_OUTPUTS = []
    LINK_OUTPUTS = [TAG_STAFF_STORE]

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            'staff': 'staff.avsc',
            StaffToDataVault2.TAG_STAFF_STORE: 'staff_store.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, staff):
        staff_store = {
            "staff_bk": staff[CONST_BK_FIELD],
            "store_bk": staff['store_bk']
        }
        self.prepare_output(staff_store, staff, staff_store.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_STAFF_STORE, staff_store)

        del staff['store_id']
        del staff['store_bk']
        yield staff


class CustomerToDataVault2(AbstractToDataVault2):
    TAG_CUSTOMER_STORE = 'customer_store'
    HUB_OUTPUTS = []
    LINK_OUTPUTS = [TAG_CUSTOMER_STORE]

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            'customer': 'customer.avsc',
            CustomerToDataVault2.TAG_CUSTOMER_STORE: 'customer_store.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, customer):
        customer_store = {
            "customer_bk": customer[CONST_BK_FIELD],
            "store_bk": customer['store_bk']
        }
        self.prepare_output(customer_store, customer, customer_store.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_CUSTOMER_STORE, customer_store)

        del customer['store_id']
        del customer['store_bk']
        yield customer


class InventoryToDataVault2(AbstractToDataVault2):
    TAG_INVENTORY_STORE = 'inventory_store'
    TAG_INVENTORY_FILM = 'inventory_film'
    HUB_OUTPUTS = []
    LINK_OUTPUTS = [TAG_INVENTORY_STORE, TAG_INVENTORY_FILM]

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            'inventory': 'inventory.avsc',
            InventoryToDataVault2.TAG_INVENTORY_STORE: 'inventory_store.avsc',
            InventoryToDataVault2.TAG_INVENTORY_FILM: 'inventory_film.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, inventory):
        inventory_store = {
            "inventory_bk": inventory[CONST_BK_FIELD],
            "store_bk": inventory['store_bk']
        }
        self.prepare_output(inventory_store, inventory, inventory_store.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_INVENTORY_STORE, inventory_store)

        inventory_film = {
            "inventory_bk": inventory[CONST_BK_FIELD],
            "film_bk": inventory['film_bk']
        }
        self.prepare_output(inventory_film, inventory, inventory_film.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_INVENTORY_FILM, inventory_film)

        del inventory['store_id']
        del inventory['store_bk']
        del inventory['film_id']
        del inventory['film_bk']
        yield inventory


class RentalToDataVault2(AbstractToDataVault2):
    TAG_RENTAL_CUSTOMER = 'rental_customer'
    TAG_RENTAL_INVENTORY = 'rental_inventory'
    TAG_RENTAL_STAFF = 'rental_staff'
    HUB_OUTPUTS = []
    LINK_OUTPUTS = [TAG_RENTAL_CUSTOMER, TAG_RENTAL_INVENTORY, TAG_RENTAL_STAFF]

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            'rental': 'rental.avsc',
            RentalToDataVault2.TAG_RENTAL_CUSTOMER: 'rental_customer.avsc',
            RentalToDataVault2.TAG_RENTAL_INVENTORY: 'rental_inventory.avsc',
            RentalToDataVault2.TAG_RENTAL_STAFF: 'rental_staff.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, rental):
        rental_customer = {
            "rental_bk": rental[CONST_BK_FIELD],
            "customer_bk": rental['customer_bk']
        }
        self.prepare_output(rental_customer, rental, rental_customer.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_RENTAL_CUSTOMER, rental_customer)

        rental_inventory = {
            "rental_bk": rental[CONST_BK_FIELD],
            "inventory_bk": rental['inventory_bk']
        }
        self.prepare_output(rental_inventory, rental, rental_inventory.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_RENTAL_INVENTORY, rental_inventory)

        rental_staff = {
            "rental_bk": rental[CONST_BK_FIELD],
            "staff_bk": rental['staff_bk']
        }
        self.prepare_output(rental_staff, rental, rental_staff.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_RENTAL_STAFF, rental_staff)

        del rental['customer_id']
        del rental['customer_bk']
        del rental['inventory_id']
        del rental['inventory_bk']
        del rental['staff_id']
        del rental['staff_bk']
        yield rental


class PaymentToDataVault2(AbstractToDataVault2):
    TAG_PAYMENT_RENTAL = 'payment_rental'
    HUB_OUTPUTS = []
    LINK_OUTPUTS = [TAG_PAYMENT_RENTAL]

    @staticmethod
    def get_avro_file(root, output_tag):
        avros = {
            'payment': 'payment.avsc',
            PaymentToDataVault2.TAG_PAYMENT_RENTAL: 'payment_rental.avsc'
        }
        return AbstractToDataVault2.load_avro_schema(root, avros[output_tag])

    def process(self, payment):
        payment_rental = {
            "payment_bk": payment[CONST_BK_FIELD],
            "rental_bk": payment['rental_bk']
        }
        self.prepare_output(payment_rental, payment, payment_rental.keys())
        yield beam.pvalue.TaggedOutput(self.TAG_PAYMENT_RENTAL, payment_rental)

        del payment['customer_id']
        del payment['staff_id']
        del payment['rental_id']
        del payment['rental_bk']
        yield payment


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
        self.yesterday_dtm = parsed_dtm - timedelta(days=1)
        self.root = known_args.root
        self.psa = os.path.join(known_args.root, 'psa', self.source)
        self.index = os.path.join(known_args.root, 'index', self.source)
        self.staging = os.path.join(known_args.root, 'staging', self.source)
        self.loading = os.path.join(known_args.root, 'incremental-load', self.source)

    def get_schema_location(self):
        return os.path.join(self.root, 'schema', 'avro')

    def get_psa_location(self, loc):
        return os.path.join(self.psa,
                            loc,
                            self.year,
                            self.month,
                            self.day,
                            loc)

    def get_loading_location(self, loc):
        return os.path.join(self.loading,
                            loc,
                            self.year,
                            self.month,
                            self.day,
                            loc)

    def get_source_index(self, loc):
        return os.path.join(self.index,
                            self.yesterday_dtm.strftime('%Y-%m-%d_') + loc)

    def get_target_index(self, loc):
        return os.path.join(self.index,
                            self.parsed_dtm.strftime('%Y-%m-%d_') + loc)

    def resolve_foreign_keys(self, entity_name, pk, data, foreign_keys, pipeline):
        data = data | 'Unkey_{0}'.format(entity_name) >> \
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
                    self.get_target_index('entity_{0}*'.format(fk_table)),
                    fk_key)
            except IOError:
                logging.info("Could not open index, incorrect load order")
                raise

            data = data | 'Rekey_{0}_{1}'.format(entity_name, fk_table) >> \
                beam.Map(lambda x: (x[fk_key], x))

            merge = ({'data': data, 'index': fk_index}) | \
                'resolve_{0}_{1}'.format(entity_name, fk_table) >> \
                beam.CoGroupByKey()
            data = merge | 'convert_{0}_{1}'.format(entity_name, fk_table) >> \
                beam.FlatMap(apply_business_key, pk, entity_name, fk_table)
        data = data | 'Rekey_{0}'.format(entity_name) >> \
            beam.Map(lambda x: (x[pk], x))

        # data | 'print_{0}'.format(fk_table) >> beam.Map(print_record)

        return data

    def run(self):
        self.pipeline_options = PipelineOptions(self.pipeline_args)
        self.pipeline_options.view_as(SetupOptions).save_main_session = True

        self.process_entity(
            entity_name='film',
            pk='film_id',
            bkey_list=['title', 'release_year'],
            Splitter=FilmToDataVault2)
        self.process_entity(
            entity_name='store',
            pk='store_id',
            bkey_list=['store_id'],
            Splitter=StoreToDataVault2)
        self.process_entity(
            entity_name='staff',
            pk='staff_id',
            bkey_list=['first_name', 'last_name'],
            foreign_keys=[('store', 'store_id')],
            Splitter=StaffToDataVault2)
        self.process_entity(
            entity_name='customer',
            pk='customer_id',
            bkey_list=['email'],
            foreign_keys=[('store', 'store_id')],
            Splitter=CustomerToDataVault2)
        self.process_entity(
            entity_name='inventory',
            pk='inventory_id',
            bkey_list=['inventory_id'],
            foreign_keys=[('film', 'film_id'), ('store', 'store_id')],
            Splitter=InventoryToDataVault2)
        self.process_entity(
            entity_name='rental',
            pk='rental_id',
            bkey_list=['rental_id'],
            foreign_keys=[('inventory', 'inventory_id'), ('customer', 'customer_id'), ('staff', 'staff_id')],
            Splitter=RentalToDataVault2)
        self.process_entity(
            entity_name='payment',
            pk='payment_id',
            bkey_list=['payment_id'],
            foreign_keys=[('customer', 'customer_id'), ('rental', 'rental_id'), ('staff', 'staff_id')],
            Splitter=PaymentToDataVault2)

    def process_entity(self,
                    entity_name,
                    pk,
                    bkey_list,
                    Splitter,
                    foreign_keys=None):

        with beam.Pipeline(options=self.pipeline_options) as p:
            # First set up a stream for the data
            data = read_file(
                p,
                entity_name,
                self.get_psa_location('public.{0}'.format(entity_name)) + '*',
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
                beam.Map(add_entity_dv_details, bkey_list, self.source)

            if foreign_keys:
                preproc_data = self.resolve_foreign_keys(
                    entity_name=entity_name,
                    pk=pk,
                    data=preproc_data,
                    foreign_keys=foreign_keys,
                    pipeline=p)

            # Group with index to be able to identify new, updated, deleted
            merge = {'data': preproc_data, 'index': index} | 'grouped_by_' + pk >> beam.CoGroupByKey()

            # Extract the data out of the records (still has index/data dict in there)
            extract = merge \
                | 'filter_' + entity_name >> beam.Filter(filter_data_rows) \
                | 'extract_' + entity_name >> beam.Map(extract_data)

            # extract | 'print_{0}'.format(entity_name) >> beam.Map(print_record)

            split_result = extract | \
                beam.ParDo(Splitter()).with_outputs(
                    *(Splitter.HUB_OUTPUTS + Splitter.LINK_OUTPUTS),
                    main=entity_name)

            for output in Splitter.HUB_OUTPUTS:
                schema = Splitter.get_avro_file(self.get_schema_location(), output)
                split_result[output] | \
                    'Write_' + output >> WriteToAvro(
                        self.get_loading_location('{0}'.format(output)),
                        schema=schema)
            for output in Splitter.LINK_OUTPUTS:
                schema = Splitter.get_avro_file(self.get_schema_location(), output)
                split_result[output] | \
                    'Write_' + output >> WriteToAvro(
                        self.get_loading_location('{0}'.format(output)),
                        schema=schema)

            schema = Splitter.get_avro_file(self.get_schema_location(), entity_name)
            split_result[entity_name] | \
                    'Write_' + entity_name >> WriteToAvro(
                        self.get_loading_location('{0}'.format(entity_name)),
                        schema=schema)

            # Update the index
            updated_index = merge | 'updated_index_' + entity_name >> beam.Map(entity_select_index_or_data, pk)
            updated_index | 'Write_index_' + entity_name >> \
                WriteToText(
                    self.get_target_index('entity_{0}'.format(entity_name)),
                    coder=JsonCoder())


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    p = DvdRentalsPipeline('dvdrentals')
    p.parse(sys.argv)
    p.run()
