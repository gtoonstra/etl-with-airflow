#!/bin/bash
cd "$(dirname "$0")"

python process_daily_full_dumps.py --root /tmp/datavault2-bigdata-example --execution_dtm $1
