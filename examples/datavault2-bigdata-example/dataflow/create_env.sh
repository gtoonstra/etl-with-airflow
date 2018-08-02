#!/bin/bash

virtualenv env
source env/bin/activate
pip install apache_beam
pip install avro

