#!/bin/bash

rm -rf /tmp/datavault2-dbt-example
mkdir -p /tmp/datavault2-dbt-example

cp -R ./examples/datavault2-dbt-example/schema /tmp/datavault2-bigdata-example/

docker-compose -f docker-compose-datavault2-dbt.yml up --abort-on-container-exit
