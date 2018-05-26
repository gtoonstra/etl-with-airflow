#!/bin/bash

rm -rf /tmp/datavault3-example
mkdir -p /tmp/datavault3-example

docker-compose -f docker-compose-datavault3.yml up --abort-on-container-exit

