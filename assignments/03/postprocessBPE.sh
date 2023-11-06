#!/bin/bash
# -*- coding: utf-8 -*-

translations_path=$1
translations_clean_path=$2

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..
src=fr
tgt=en
data=$base/data/$tgt-$src/

# change into base directory to ensure paths are valid
cd $base

python3 <<EOF

translations_path = "$translations_path"
translations_clean_path = "$translations_clean_path"

with open(translations_path, 'rb') as file:
    # Read the binary data from the file
    binary_data = file.read()

# Remove occurrences of b'@@ ' and b'@@' from the binary data
modified_data = binary_data.replace(b'@@ ', b'').replace(b'@@', b'')

# Write the modified binary data back to the file
with open(translations_clean_path, 'wb') as file:
    file.write(modified_data)
EOF

echo "done!"
