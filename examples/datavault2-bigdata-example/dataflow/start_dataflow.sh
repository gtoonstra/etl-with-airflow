#!/bin/bash
cd "$(dirname "$0")"

python dvdrentals.py --root /tmp/datavault2-bigdata-example --execution_dtm $1
