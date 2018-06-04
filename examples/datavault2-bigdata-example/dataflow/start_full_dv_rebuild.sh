#!/bin/bash
cd "$(dirname "$0")"

python full_dv_rebuild.py --root /tmp/datavault2-bigdata-example --execution_dtm $1
