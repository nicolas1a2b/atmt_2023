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

# create preprocessed directory
mkdir -p $data/preprocessedBPE/


#Standard
cat "data/en-fr/raw/train.fr" "data/en-fr/raw/train.en" | subword-nmt learn-bpe -s 2000 -o "data/en-fr/preprocessedBPE/codes_file"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" < "data/en-fr/raw/train.fr" | subword-nmt get-vocab > "data/en-fr/preprocessedBPE/dict.fr"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" < "data/en-fr/raw/train.en"| subword-nmt get-vocab > "data/en-fr/preprocessedBPE/dict.en"

subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" --vocabulary "data/en-fr/preprocessedBPE/dict.fr" --vocabulary-threshold 50 < "data/en-fr/raw/train.fr"  > "data/en-fr/preprocessedBPE/train.fr"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" --vocabulary "data/en-fr/preprocessedBPE/dict.en" --vocabulary-threshold 50 < "data/en-fr/raw/train.en" > "data/en-fr/preprocessedBPE/train.en"


#Test
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" --vocabulary "data/en-fr/preprocessedBPE/dict.fr" --vocabulary-threshold 50 < "data/en-fr/raw/test.fr"  > "data/en-fr/preprocessedBPE/test.fr"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" --vocabulary "data/en-fr/preprocessedBPE/dict.en" --vocabulary-threshold 50 < "data/en-fr/raw/test.en" > "data/en-fr/preprocessedBPE/test.en"

#Tiny
cat "data/en-fr/raw/tiny_train.fr" "data/en-fr/raw/tiny_train.en" | subword-nmt learn-bpe -s 1000 -o "data/en-fr/preprocessedBPE/codes_file_tiny"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file_tiny" < "data/en-fr/raw/tiny_train.fr" | subword-nmt get-vocab > "data/en-fr/preprocessedBPE/dict_tiny.fr"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file_tiny" < "data/en-fr/raw/tiny:train.en"| subword-nmt get-vocab > "data/en-fr/preprocessedBPE/dict_tiny.en"

subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file_tiny" --vocabulary "data/en-fr/preprocessedBPE/dict_tiny.fr" --vocabulary-threshold 50 < "data/en-fr/raw/tiny_train.fr"  > "data/en-fr/preprocessedBPE/tiny_train.fr"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file_tiny" --vocabulary "data/en-fr/preprocessedBPE/dict_tiny.en" --vocabulary-threshold 50 < "data/en-fr/raw/tiny_train.en" > "data/en-fr/preprocessedBPE/tiny_train.en"

#Valid
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" --vocabulary "data/en-fr/preprocessedBPE/dict.fr" --vocabulary-threshold 50 < "data/en-fr/raw/valid.fr"  > "data/en-fr/preprocessedBPE/valid.fr"
subword-nmt apply-bpe -c "data/en-fr/preprocessedBPE/codes_file" --vocabulary "data/en-fr/preprocessedBPE/dict.en" --vocabulary-threshold 50 < "data/en-fr/raw/valid.en" > "data/en-fr/preprocessedBPE/valid.en"

# preprocess all files for model training
python preprocess.py --target-lang $tgt --source-lang $src --dest-dir $data/preparedBPE/ --train-prefix $data/preprocessedBPE/train --valid-prefix $data/preprocessedBPE/valid --test-prefix $data/preprocessedBPE/test --tiny-train-prefix $data/preprocessedBPE/tiny_train --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000

echo "done!"
