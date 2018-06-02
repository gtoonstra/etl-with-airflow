#!/bin/bash

rm -rf /tmp/datavault2-bigdata-example
mkdir -p /tmp/datavault2-bigdata-example

docker-compose -f docker-compose-datavault2-bigdata.yml up --abort-on-container-exit

