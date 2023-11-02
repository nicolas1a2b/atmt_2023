#!/bin/bash
# -*- coding: utf-8 -*-

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..
src=fr
tgt=en
data=$base/data/$tgt-$src/

# change into base directory to ensure paths are valid
cd $base

python3 <<EOF
with open('assignments/03/translations/translations.txt', 'rb') as file:
    # Read the binary data from the file
    binary_data = file.read()

# Remove occurrences of b'@@ ' and b'@@' from the binary data
modified_data = binary_data.replace(b'@@ ', b'').replace(b'@@', b'')

# Write the modified binary data back to the file
with open('output_file.txt', 'wb') as file:
    file.write(modified_data)
EOF




echo "done!"
