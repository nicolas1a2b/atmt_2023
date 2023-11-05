#!/bin/bash
# -*- coding: utf-8 -*-

merge_operations=$1
vocab_threshold=$2

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..
src=fr
tgt=en
data_raw=$base/data/$tgt-$src/
data=$base/data/$tgt-$src/A3/

preprocessed_folder=$"preprocessed_${merge_operations}_${vocab_threshold}"
prepared_folder=$"prepared_${merge_operations}_${vocab_threshold}"

# change into base directory to ensure paths are valid
cd $base

# create $preprocessed_folder directory
mkdir -p $data/$preprocessed_folder/

# normalize and tokenize raw data
cat $data_raw/raw/train.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q > $data/$preprocessed_folder/train.$src.p
cat $data_raw/raw/train.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q > $data/$preprocessed_folder/train.$tgt.p

# train truecase models
perl moses_scripts/train-truecaser.perl --model $data/$preprocessed_folder/tm.$src --corpus $data/$preprocessed_folder/train.$src.p
perl moses_scripts/train-truecaser.perl --model $data/$preprocessed_folder/tm.$tgt --corpus $data/$preprocessed_folder/train.$tgt.p

# apply truecase models to splits
cat $data/$preprocessed_folder/train.$src.p | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$src > $data/$preprocessed_folder/train.$src
cat $data/$preprocessed_folder/train.$tgt.p | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$tgt > $data/$preprocessed_folder/train.$tgt

# prepare remaining splits with learned models
for split in valid test tiny_train
do
    cat $data_raw/raw/$split.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$src > $data/$preprocessed_folder/$split.$src
    cat $data_raw/raw/$split.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q | perl moses_scripts/truecase.perl --model $data/$preprocessed_folder/tm.$tgt > $data/$preprocessed_folder/$split.$tgt
done

# remove tmp files
rm $data/$preprocessed_folder/train.$src.p
rm $data/$preprocessed_folder/train.$tgt.p

#Standard
cat $data/$preprocessed_folder/train.$src $data/$preprocessed_folder/train.$tgt | subword-nmt learn-bpe -s $merge_operations -o $data/$preprocessed_folder/codes_file
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file < $data/$preprocessed_folder/train.$src | subword-nmt get-vocab > $data/$preprocessed_folder/dict.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file < $data/$preprocessed_folder/train.$tgt | subword-nmt get-vocab > $data/$preprocessed_folder/dict.$tgt

subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/train.$src  > $data/$preprocessed_folder/train_bpe.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/train.$tgt  > $data/$preprocessed_folder/train_bpe.$tgt

#Test
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/valid.$src  > $data/$preprocessed_folder/test_bpe.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/valid.$tgt > $data/$preprocessed_folder/test_bpe.$tgt

#Tiny
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/tiny_train.$src  > $data/$preprocessed_folder/tiny_train_bpe.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/tiny_train.$tgt > $data/$preprocessed_folder/tiny_train_bpe.$tgt

#Valid
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$src --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/valid.$src  > $data/$preprocessed_folder/valid_bpe.$src
subword-nmt apply-bpe -c $data/$preprocessed_folder/codes_file --vocabulary $data/$preprocessed_folder/dict.$tgt --vocabulary-threshold $vocab_threshold < $data/$preprocessed_folder/valid.$tgt > $data/$preprocessed_folder/valid_bpe.$tgt

rm $data/$preprocessed_folder/train.$src
rm $data/$preprocessed_folder/train.$tgt
rm $data/$preprocessed_folder/tiny_train.$src
rm $data/$preprocessed_folder/tiny_train.$tgt
rm $data/$preprocessed_folder/test.$src
rm $data/$preprocessed_folder/test.$tgt
rm $data/$preprocessed_folder/valid.$src
rm $data/$preprocessed_folder/valid.$tgt

# preprocess all files for model training
python preprocess.py --target-lang $tgt --source-lang $src --dest-dir $data/$prepared_folder/ --train-prefix $data/$preprocessed_folder/train_bpe --valid-prefix $data/$preprocessed_folder/valid_bpe --test-prefix $data/$preprocessed_folder/test_bpe --tiny-train-prefix $data/$preprocessed_folder/tiny_train_bpe --vocab-src $data/$preprocessed_folder/dict.fr  --vocab-trg $data/$preprocessed_folder/dict.en --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000

echo "done!"
