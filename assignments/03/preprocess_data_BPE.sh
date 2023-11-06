#!/bin/bash
# -*- coding: utf-8 -*-

# Defines the amount of merge operations and the vocab threshold based on the parameters provided
merge_operations=$1
vocab_threshold=$2

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..
src=fr
tgt=en
data_raw=$base/data/$tgt-$src/
data=$base/data/$tgt-$src/A3/

# Create Folder names
preprocessed_folder=$"preprocessed_${merge_operations}_${vocab_threshold}"
prepared_folder=$"prepared_${merge_operations}_${vocab_threshold}"

# change into base directory to ensure paths are valid
cd $base

# create $preprocessed_folder directory
mkdir -p $data/$preprocessed_folder/

# --- Preprocessing Step 1/2: Similar to the original preprocessing
# normalize and tokenize raw data
cat $data_raw/raw/train.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q > $data/$preprocessed_folder/train_intermediate.$src.p
cat $data_raw/raw/train.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q > $data/$preprocessed_folder/train_intermediate.$tgt.p

# train truecase models
perl moses_scripts/train-truecaser.perl --model $data/$preprocessed_folder/tm.$src --corpus $data/$preprocessed_folder/train_intermediate.$src.p
perl moses_scripts/train-truecaser.perl --model $data/$preprocessed_folder/tm.$tgt --corpus $data/$preprocessed_folder/train_intermediate.$tgt.p

# apply truecase models to splits
cat $data/$preprocessed_folder/train_intermediate.$src.p | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$src > $data/$preprocessed_folder/train_intermediate.$src
cat $data/$preprocessed_folder/train_intermediate.$tgt.p | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$tgt > $data/$preprocessed_folder/train_intermediate.$tgt

# prepare remaining splits with learned models
for split in valid test tiny_train
do
    cat $data_raw/raw/$split.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$src > $data/$preprocessed_folder/$split\_intermediate.$src
    cat $data_raw/raw/$split.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$tgt > $data/$preprocessed_folder/$split\_intermediate.$tgt
done

# remove tmp files
rm $data/$preprocessed_folder/train_intermediate.$src.p
rm $data/$preprocessed_folder/train_intermediate.$tgt.p


# --- Preprocessing Step 2/2: Based on Sennrich BPE subword-nmt https://github.com/rsennrich/subword-nmt
#Standard
cat $data/$preprocessed_folder/train_intermediate.$src $data/$preprocessed_folder/train_intermediate.$tgt | subword-nmt learn-bpe -s $merge_operations -o $data/$preprocessed_folder/codes_file
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file < $data/$preprocessed_folder/train_intermediate.$src | subword-nmt get-vocab > $data/$preprocessed_folder/dict.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file < $data/$preprocessed_folder/train_intermediate.$tgt | subword-nmt get-vocab > $data/$preprocessed_folder/dict.$tgt

subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/train_intermediate.$src  > $data/$preprocessed_folder/train.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/train_intermediate.$tgt  > $data/$preprocessed_folder/train.$tgt

#Test
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/test_intermediate.$src  > $data/$preprocessed_folder/test.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/test_intermediate.$tgt > $data/$preprocessed_folder/test.$tgt

#Tiny
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/tiny_train_intermediate.$src  > $data/$preprocessed_folder/tiny_train.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/tiny_train_intermediate.$tgt > $data/$preprocessed_folder/tiny_train.$tgt

#Valid
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/valid_intermediate.$src  > $data/$preprocessed_folder/valid.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/valid_intermediate.$tgt > $data/$preprocessed_folder/valid.$tgt

rm $data/$preprocessed_folder/train_intermediate.$src
rm $data/$preprocessed_folder/train_intermediate.$tgt
rm $data/$preprocessed_folder/tiny_train_intermediate.$src
rm $data/$preprocessed_folder/tiny_train_intermediate.$tgt
rm $data/$preprocessed_folder/test_intermediate.$src
rm $data/$preprocessed_folder/test_intermediate.$tgt
rm $data/$preprocessed_folder/valid_intermediate.$src
rm $data/$preprocessed_folder/valid_intermediate.$tgt

# preprocess all files for model training
python preprocess.py --target-lang $tgt --source-lang $src --dest-dir $data/$prepared_folder/ --train-prefix $data/$preprocessed_folder/train --valid-prefix $data/$preprocessed_folder/valid --test-prefix $data/$preprocessed_folder/test --tiny-train-prefix $data/$preprocessed_folder/tiny_train --vocab-src $data/$preprocessed_folder/dict.fr  --vocab-trg $data/$preprocessed_folder/dict.en --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000

# Copying the Dictionary Over to the prepared folder
cp $data/$preprocessed_folder/dict.fr $data/$prepared_folder/
cp $data/$preprocessed_folder/dict.en $data/$prepared_folder/

echo "done!"
