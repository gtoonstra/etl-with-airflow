import argparse
import csv
from datetime import datetime
import hashlib
import logging
import os
import re
import sys

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.io.filebasedsource import FileBasedSource
from apache_beam.io.filebasedsink import FileBasedSink
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions

from utils.filesource import CsvFileSource
from utils.filesink import CsvFileSink, CsvTupleFileSink


def print_line(record):
    print(record)


def get_business_key(record, list_of_keys):
    s = ''
    first = True
    for key in list_of_keys:
        if not first:
            s += '|'
        val = record.get(key, '')
        s += str(val).strip().upper()
        first = False
    return s


def generate_bk(record, bk_fields):
    d = record[1]
    bk = get_business_key(record[1], bk_fields)
    m = hashlib.md5()
    m.update(bk)
    d['dv_bk'] = m.hexdigest().upper()
    return (record[0], d)


def filter_bk(record):
    return (record[0], record[1]['dv_bk'])


def co_group_op_1(record, list_attribute, bks, key_attribute):
    list_of_objects = record[1][list_attribute]
    entity_bk = record[1][bks][0]
    output_recs = []
    for obj in list_of_objects:
        entity_id = obj[key_attribute]
        output_recs.append((entity_id, entity_bk))
    return output_recs


def co_group_op_2(record, list_attribute, bks):
    list_attributes = record[1][list_attribute]
    bk_object = record[1][bks][0]
    output_recs = []
    for entity_bk in list_attributes:
        output_recs.append((bk_object, entity_bk))
    return output_recs


def check_missing(record, side):
    if len(record[1][side]) == 0:
        yield record


def grab_from_either(record, left, right):
    if len(record[1][left]) > 0:
        yield (record[0], record[1][left][0])
    else:
        yield (record[0], record[1][right][0])


def extract_data_rec(record):
    yield record[1]


class DvdRentalsPipeline(object):
    def __init__(self, source, *args, **kwargs):
        self.psa = None
        self.index = None
        self.staging = None
        self.source = source
        self.hubs = {}
        self.indexes = {}
        self.pcols = {}
        self.intersections = []

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

        self.psa = os.path.join(known_args.root, 'psa', self.source)
        self.index = os.path.join(known_args.root, 'index', self.source)
        self.staging = os.path.join(known_args.root, 'staging', self.source)
        parsed_dtm = datetime.strptime(known_args.execution_dtm, '%Y-%m-%dT%H:%M:%S')
        self.year = str(parsed_dtm.year)
        self.month = '{0:02d}'.format(parsed_dtm.month)
        self.day = '{0:02d}'.format(parsed_dtm.day)

    def add_hub(self, table_name, table_obj):
        self.hubs[table_name] = table_obj

    def add_index(self, index_name, index_obj):
        self.indexes[index_name] = index_obj

    def get_index_location(self, key):
        return os.path.join(self.index, key)

    def get_data_location(self, key, include_date=False):
        if include_date:
            return os.path.join(self.psa, key, self.year, self.month, self.day, key)
        return os.path.join(self.psa, key, key)

    def get_staging_location(self, key, prefix):
        return os.path.join(self.staging, self.year, self.month, self.day, key, prefix)

    def calc_intersection(self, left, right, output, new, removed, header):
        self.intersections.append((left, right, output, new, removed, header))

    def run(self):
        pipeline_options = PipelineOptions(self.pipeline_args)
        pipeline_options.view_as(SetupOptions).save_main_session = True
        with beam.Pipeline(options=pipeline_options) as p:
            # Helper: read a tab-separated key-value mapping from a text file,
            # escape all quotes/backslashes, and convert it a PCollection of
            # (key, value) pairs.
            def read_data_file(label, file_pattern, pk, add_source=False, dictionary_output=True):
                return (p
                    | 'Read: %s' % label >> beam.io.Read(CsvFileSource(file_pattern, 
                                                                       add_source=add_source,
                                                                       dictionary_output=dictionary_output))
                    | 'Key: %s' % label >> beam.Map(lambda x: (x[pk], x)))

            def read_index_file(label, file_pattern, pk, bk, add_source=False, dictionary_output=True):
                return (p
                    | 'Read: %s' % label >> beam.io.Read(CsvFileSource(file_pattern, 
                                                                       add_source=add_source,
                                                                       dictionary_output=dictionary_output))
                    | 'Tuple: %s' % label >> beam.Map(lambda x: (x[pk], x[bk])))

            for key, value in self.indexes.items():
                self.pcols[value['name']] = read_index_file(key,
                    self.get_index_location(key) + '*',
                    value['pk'],
                    value['bk'])
                # self.pcols[value['name']] | 'print3' + value['name'] >> beam.Map(print_line) 

            for key, value in self.hubs.items():
                self.pcols[value['name']] = read_data_file(key,
                    self.get_data_location(key, value.get('include_date', None)) + '*',
                    value['pk'],
                    add_source=True)
                self.pcols['full_' + value['name']] = \
                    self.pcols[value['name']] | 'full_' + key >> beam.Map(generate_bk, value['bk'])
                self.pcols['bk_' + value['name']] = \
                    self.pcols['full_' + value['name']] | 'bk_' + key >> beam.Map(filter_bk)

                self.pcols['extract_' + value['name']] = \
                    self.pcols['full_' + value['name']] | 'extract_' + value['name'] >> beam.FlatMap(extract_data_rec)

                self.pcols['extract_' + value['name']] | 'Write_full_' + value['name'] >> beam.io.Write(
                    CsvFileSink(self.get_staging_location(value['name'], 'current'), header=value['header']))

                # self.pcols['bk_' + value['name']] | 'print' + value['name'] >> beam.Map(print_line) 

            for (index, data, intersection, new, removed, header) in self.intersections:
                self.pcols[intersection] = \
                    ({index: self.pcols[index], 
                        data: self.pcols['bk_' + data]}) | intersection >> beam.CoGroupByKey()
                self.pcols[new] = self.pcols[intersection] | new + '_' + data >> beam.FlatMap(check_missing, index)
                self.pcols[removed] = self.pcols[intersection] | removed + '_' + data >> beam.FlatMap(check_missing, data)

                updated_index = self.pcols[intersection] | 'updatedindex_' + data >> beam.FlatMap(grab_from_either, index, data)
                updated_index | 'Write_' + index >> beam.io.Write(
                    CsvTupleFileSink(self.get_index_location(index), header=header))

                self.pcols[new] | 'new_' + data >> beam.FlatMap(grab_from_either, index, data) \
                    | 'Write_new_' + data >> beam.io.Write(
                        CsvTupleFileSink(self.get_staging_location(data, 'new'), header=header))
                self.pcols[removed] | 'removed_' + data >> beam.FlatMap(grab_from_either, index, data) \
                    | 'Write_removed_' + data >> beam.io.Write(
                        CsvTupleFileSink(self.get_staging_location(data, 'removed'), header=header))

                # self.pcols[intersection] | 'print2' + data >> beam.Map(print_line) 


            """
            film_actor = read_csv_file('film_actor', known_args.film_actor, 'actor_id')
            grouped_by_actor = \
                ({'film_actors': film_actor, 'actors': actor_p}) | 'group_by_actor' >> beam.CoGroupByKey()

            remap = grouped_by_actor | 'switch_pk_filmid' >> beam.FlatMap(by_film_id)
            grouped_by_film = \
                ({'remap': remap, 'films': film_p}) | 'group_by_film' >> beam.CoGroupByKey()

            remap_film = grouped_by_film | 'film_actor_bks' >> beam.FlatMap(film_bk_actor_bk)
            # remap_film | 'print' >> beam.Map(print_line)
            # Write the output using a "Write" transform that has side effects.
            remap_film | 'Write film actor' >> beam.io.Write(
                CsvFileSink(known_args.output_film_actor, header=['film_bk', 'actor_bk']))
            film_p | 'Write film' >> beam.io.Write(
                CsvFileSink(known_args.index_film, header=['film_id', 'film_bk']))

            actor_p | 'Write actor' >> beam.io.Write(
                CsvFileSink(known_args.index_actor, header=['actor_id', 'actor_bk']))
            actor_new | 'Write actor' >> beam.io.Write(
                CsvFileSink(known_args.index_actor, header=['actor_id', 'actor_bk']))
            actor_removed | 'Write actor' >> beam.io.Write(
                CsvFileSink(known_args.index_actor, header=['actor_id', 'actor_bk']))
            """


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    p = DvdRentalsPipeline('dvdrentals')
    p.parse(sys.argv)

    p.add_hub('public.actor', {'pk': 'actor_id', 'bk': ['first_name', 'last_name'], 'name': 'actor',
        'header': ['dv_bk', 'dv_source', 'dv_load_dtm', 'first_name', 'last_name', 'last_update']})
    p.add_hub('public.film', {'pk': 'film_id', 'bk': ['title', 'release_year'], 'name': 'film',
        'header': ['dv_bk', 'dv_source', 'dv_load_dtm', 'rating', 'fulltext', 'replacement_cost', 
        'description', 'title', 'language_id', 'rental_duration', 'special_features', 'rental_rate', 'length',
        'last_update', 'release_year']})
    p.add_hub('public.payment', {'pk': 'payment_id', 'bk': ['payment_id'], 'name': 'payment',
        'header': ['dv_bk', 'dv_source', 'dv_load_dtm', 'amount', 'payment_date'],
        'include_date': True})
    p.add_index('actorindex', {'pk': 'actor_id', 'name': 'actorindex', 'bk': 'actor_bk'})
    p.add_index('filmindex', {'pk': 'film_id', 'name': 'filmindex', 'bk': 'film_bk'})
    p.add_index('paymentindex', {'pk': 'payment_id', 'name': 'paymentindex', 'bk': 'payment_bk'})
    p.calc_intersection('actorindex', 'actor', 'actor_intersection', 'actor_new', 'actor_removed', ['actor_id', 'actor_bk'])
    p.calc_intersection('filmindex', 'film', 'film_intersection', 'film_new', 'film_removed', ['film_id', 'film_bk'])
    p.calc_intersection('paymentindex', 'payment', 'payment_intersection', 'payment_new', 'payment_removed', ['payment_id', 'payment_bk'])
    p.run()
