#!/bin/bash

PGPASSWORD=db_owner psql -h localhost -p 5432 -U db_owner -d orders -f tables.sql

