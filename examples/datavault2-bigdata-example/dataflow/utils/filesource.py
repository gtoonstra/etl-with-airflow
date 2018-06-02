import csv
import os
from functools import partial

import apache_beam as beam
from apache_beam import coders
from apache_beam.io import filesystem


class CsvFileSource(beam.io.filebasedsource.FileBasedSource):
    """ A source for a GCS or local comma-separated-file
    Parses a text file assuming newline-delimited lines,
    and comma-delimited fields. Assumes UTF-8 encoding.
    """

    def __init__(self, 
                 file_pattern,
                 compression_type=filesystem.CompressionTypes.AUTO,
                 delimiter='\x01', 
                 lineterminator='\r\n', 
                 header=True, 
                 dictionary_output=True,
                 validate=True,
                 add_source=False):
        """ Initialize a CSVFileSource.
        Args:
            delimiter: The delimiter character in the CSV file.
            header: Whether the input file has a header or not.
                Default: True
            dictionary_output: The kind of records that the CsvFileSource outputs.
                If True, then it will output dict()'s, if False it will output list()'s.
                Default: True
        Raises:
            ValueError: If the input arguments are not consistent.
        """
        self.delimiter = delimiter
        self.header = header
        self.dictionary_output = dictionary_output
        self.add_source = add_source

        # Can't just split anywhere
        super(self.__class__, self).__init__(
            file_pattern,
            compression_type=compression_type,
            validate=validate,
            splittable=False)

        if not self.header and dictionary_output:
            raise ValueError(
                'header is required for the CSV reader to provide dictionary output')

    def read_records(self, file_name, range_tracker):
        # If a multi-file pattern was specified as a source then make sure the
        # start/end offsets use the default values for reading the entire file.
        headers = None
        self._file = self.open_file(file_name)

        source = self.get_source(file_name)
        reader = csv.reader(_Fileobj2Iterator(self._file), delimiter=self.delimiter)

        for i, rec in enumerate(reader):
            if (self.header or self.dictionary_output) and i == 0:
                headers = rec
                continue

            if self.dictionary_output:
                res = {header:val for header, val in zip(headers,rec)}
                if self.add_source:
                    res['dv_source'] = source
            else:
                res = rec
            yield res

    def get_source(self, file_name):
        source = None
        head, tail = os.path.split(file_name)
        while len(tail) > 0:
            if tail == 'psa':
                break
            source = tail
            head, tail = os.path.split(head)
        return source


class _Fileobj2Iterator(object):

        def __init__(self, obj):
            self._obj = obj

        def __iter__(self):
            return self

        def next(self):
            line = self._obj.readline()
            if line == None or line == '':
                    raise StopIteration
            return line