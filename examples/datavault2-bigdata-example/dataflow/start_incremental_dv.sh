#!/bin/bash
cd "$(dirname "$0")"

python incremental_dv.py --root /tmp/datavault2-bigdata-example --execution_dtm $1
