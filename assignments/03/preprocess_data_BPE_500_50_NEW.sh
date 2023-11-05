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

# create preprocessedBPE500_50_NEW directory
mkdir -p $data/preprocessedBPE500_50_NEW/

# normalize and tokenize raw data
cat $data/raw/train.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q > $data/preprocessedBPE500_50_NEW/train.$src.p
cat $data/raw/train.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q > $data/preprocessedBPE500_50_NEW/train.$tgt.p

# train truecase models
perl moses_scripts/train-truecaser.perl --model $data/preprocessedBPE500_50_NEW/tm.$src --corpus $data/preprocessedBPE500_50_NEW/train.$src.p
perl moses_scripts/train-truecaser.perl --model $data/preprocessedBPE500_50_NEW/tm.$tgt --corpus $data/preprocessedBPE500_50_NEW/train.$tgt.p

# apply truecase models to splits
cat $data/preprocessedBPE500_50_NEW/train.$src.p | perl moses_scripts/truecase.perl --model $data/preprocessedBPE500_50_NEW/tm.$src > $data/preprocessedBPE500_50_NEW/train.$src
cat $data/preprocessedBPE500_50_NEW/train.$tgt.p | perl moses_scripts/truecase.perl --model $data/preprocessedBPE500_50_NEW/tm.$tgt > $data/preprocessedBPE500_50_NEW/train.$tgt

# prepare remaining splits with learned models
for split in valid test tiny_train
do
    cat $data/raw/$split.$src | perl moses_scripts/normalize-punctuation.perl -l $src | perl moses_scripts/tokenizer.perl -l $src -a -q | perl moses_scripts/truecase.perl --model $data/preprocessedBPE500_50_NEW/tm.$src > $data/preprocessedBPE500_50_NEW/$split.$src
    cat $data/raw/$split.$tgt | perl moses_scripts/normalize-punctuation.perl -l $tgt | perl moses_scripts/tokenizer.perl -l $tgt -a -q | perl moses_scripts/truecase.perl --model $data/preprocessedBPE500_50_NEW/tm.$tgt > $data/preprocessedBPE500_50_NEW/$split.$tgt
done

# remove tmp files
rm $data/preprocessedBPE500_50_NEW/train.$src.p
rm $data/preprocessedBPE500_50_NEW/train.$tgt.p

#Standard
cat $data/preprocessedBPE500_50_NEW/train.$src $data/preprocessedBPE500_50_NEW/train.$tgt | subword-nmt learn-bpe -s 500 -o $data/preprocessedBPE500_50_NEW/codes_file
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file < $data/preprocessedBPE500_50_NEW/train.$src | subword-nmt get-vocab > $data/preprocessedBPE500_50_NEW/dict.$src
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file < $data/preprocessedBPE500_50_NEW/train.$tgt | subword-nmt get-vocab > $data/preprocessedBPE500_50_NEW/dict.$tgt

subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$src --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/train.$src  > $data/preprocessedBPE500_50_NEW/train_bpe.$src
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$tgt --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/train.$tgt  > $data/preprocessedBPE500_50_NEW/train_bpe.$tgt

#Test
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$src --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/valid.$src  > $data/preprocessedBPE500_50_NEW/test_bpe.$src
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$tgt --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/valid.$tgt > $data/preprocessedBPE500_50_NEW/test_bpe.$tgt

#Tiny
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$src --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/tiny_train.$src  > $data/preprocessedBPE500_50_NEW/tiny_train_bpe.$src
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$tgt --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/tiny_train.$tgt > $data/preprocessedBPE500_50_NEW/tiny_train_bpe.$tgt

#Valid
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$src --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/valid.$src  > $data/preprocessedBPE500_50_NEW/valid_bpe.$src
subword-nmt apply-bpe -c $data/preprocessedBPE500_50_NEW/codes_file --vocabulary $data/preprocessedBPE500_50_NEW/dict.$tgt --vocabulary-threshold 50 < $data/preprocessedBPE500_50_NEW/valid.$tgt > $data/preprocessedBPE500_50_NEW/valid_bpe.$tgt

rm $data/preprocessedBPE500_50_NEW/train.$src
rm $data/preprocessedBPE500_50_NEW/train.$tgt
rm $data/preprocessedBPE500_50_NEW/tiny_train.$src
rm $data/preprocessedBPE500_50_NEW/tiny_train.$tgt
rm $data/preprocessedBPE500_50_NEW/test.$src
rm $data/preprocessedBPE500_50_NEW/test.$tgt
rm $data/preprocessedBPE500_50_NEW/valid.$src
rm $data/preprocessedBPE500_50_NEW/valid.$tgt

# preprocess all files for model training
python preprocess.py --target-lang $tgt --source-lang $src --dest-dir $data/preparedBPE500_50_NEW/ --train-prefix $data/preprocessedBPE500_50_NEW/train_bpe --valid-prefix $data/preprocessedBPE500_50_NEW/valid_bpe --test-prefix $data/preprocessedBPE500_50_NEW/test_bpe --tiny-train-prefix $data/preprocessedBPE500_50_NEW/tiny_train_bpe --vocab-src $data/preprocessedBPE500_50_NEW/dict.fr  --vocab-trg $data/preprocessedBPE500_50_NEW/dict.en --threshold-src 1 --threshold-tgt 1 --num-words-src 4000 --num-words-tgt 4000

echo "done!"
