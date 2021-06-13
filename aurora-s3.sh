#!/usr/bin/env bash

# source /etc/environment

export tablenames=$1

for table_name in $tablenames
do
    export s3_path="s3://honest-eis-staging/aurora-s3-test/$table_name"
    echo "$table"
    echo `date "+DATE: %m/%d/%y %H:%M:%S"`
    mysql -h${AURORA_HOST} -u${AURORA_USER} -p${AURORA_PASS} www -e "SELECT * FROM $table_name INTO OUTFILE S3 '$s3_path' FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"';"

    psql --host=${REDSHIFT_HOST} --port=${REDSHIFT_PORT} --username=${REDSHIFT_USER} --dbname=${REDSHIFT_DB} -c "
        truncate table ${REDSHIFT_SCHEMA}.$table_name;
        copy ${REDSHIFT_SCHEMA}.$table_name from '$s3_path'
        credentials 'aws_access_key_id=${s3_access_key};aws_secret_access_key=${s3_secret_key}'
        delimiter '|' escape removequotes dateformat as 'YYYY-MM-DD' maxerror as 2000;
    "

done


