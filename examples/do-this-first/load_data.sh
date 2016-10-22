#!/bin/bash

PGPASSWORD=db_owner psql -h localhost -p 5432 -U db_owner -d orders -f populate_tables.sql
PGPASSWORD=db_owner psql -h localhost -p 5432 -U db_owner -d dwh -f dwh_tables.sql

