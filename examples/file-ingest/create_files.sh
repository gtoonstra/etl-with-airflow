#!/bin/bash

ETL_SOURCE=/tmp/etl_source_system/
ETL_ARCHIVE=/tmp/etl_archive/
ETL_TARGET=/tmp/etl_target/

cd /tmp

mkdir -p $ETL_SOURCE
mkdir -p $ETL_ARCHIVE
mkdir -p $ETL_TARGET

cd $ETL_SOURCE
rm *
cd $ETL_ARCHIVE
rm -r *
cd $ETL_TARGET
rm *

cd $ETL_SOURCE

for i in {1..7}
do
    DAYSAGO="-${i} day"
    DATE=`date --date="$DAYSAGO" +%Y%m%d`
    touch some_file_pattern_$DATE
done

for i in {1..7}
do
    DAYSAGO="-${i} day"
    DATE=`date --date="$DAYSAGO" +%Y%m%d`
    touch some_other_file_pattern_$DATE
done

