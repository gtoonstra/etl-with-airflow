import csv

import apache_beam as beam
from apache_beam.io import filebasedsink
from apache_beam.io.filesystem import CompressionTypes
from apache_beam.coders import coders


class CsvFileSink(filebasedsink.FileBasedSink):
    def __init__(self,
               file_path_prefix,
               file_name_suffix='',
               append_trailing_newlines=True,
               num_shards=0,
               shard_name_template=None,
               coder=coders.ToStringCoder(),
               compression_type=CompressionTypes.AUTO,
               header=[],
               delimiter='\x01',
               lineterminator='\r\n'):
        super(CsvFileSink, self).__init__(
            file_path_prefix=file_path_prefix,
            file_name_suffix=file_name_suffix,
            num_shards=num_shards,
            shard_name_template=shard_name_template,
            coder=coder,
            mime_type='text/plain',
            compression_type=compression_type)
        self.header = header
        self.delimiter = delimiter
        self.lineterminator = lineterminator

    def open(self, temp_path):
        file_handle = super(CsvFileSink, self).open(temp_path)
        csvwriter = csv.DictWriter(
            file_handle, 
            delimiter=self.delimiter,
            lineterminator=self.lineterminator,
            quotechar='',
            quoting=csv.QUOTE_NONE,
            extrasaction='ignore',
            fieldnames=self.header)
        csvwriter.myfile = file_handle
        csvwriter.writeheader()
        return csvwriter

    def write_record(self, csvwriter, value):
        """Writes a single encoded record."""
        csvwriter.writerow(value)

    def close(self, csvwriter):
        """Finalize and close the file handle returned from ``open()``.
        Called after all records are written.
        By default, calls ``file_handle.close()`` iff it is not None.
        """
        if csvwriter.myfile is not None:
            csvwriter.myfile.close()
            csvwriter.myfile = None


class CsvTupleFileSink(CsvFileSink):
    def __init__(self,
               file_path_prefix,
               file_name_suffix='',
               append_trailing_newlines=True,
               num_shards=0,
               shard_name_template=None,
               coder=coders.ToStringCoder(),
               compression_type=CompressionTypes.AUTO,
               header=[],
               delimiter='\x01',
               lineterminator='\r\n'):
        super(CsvTupleFileSink, self).__init__(
            file_path_prefix=file_path_prefix,
            file_name_suffix=file_name_suffix,
            num_shards=num_shards,
            shard_name_template=shard_name_template,
            coder=coder,
            compression_type=compression_type,
            header=header,
            delimiter=delimiter,
            lineterminator=lineterminator)
        self.header = header
        self.delimiter = delimiter
        self.lineterminator = lineterminator

    def write_record(self, csvwriter, value):
        """Writes a single encoded record."""
        d = {}
        for k, v in zip(self.header, value):
            d[k] = v
        csvwriter.writerow(d)