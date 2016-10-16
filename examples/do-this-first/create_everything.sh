#!/bin/bash

# For MAC OS, maybe enable this if you're running the simple PG app;
# export PATH=/Applications/Postgres.app/Contents/Versions/9.5/bin:$PATH

if [ "$(whoami)" == "postgres" ] ; then
    echo "Running as postgres, now creating user and database."
else
    echo "This script should be run as the postgres user. Exiting."
    exit -1
fi

echo "Removing old database and user first"
psql -f database_user.sql

