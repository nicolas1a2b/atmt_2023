# How to run the BPE implementation for A3
 - Authors: Nicolas Fazli Kohler & Eric Szabo Felix 
 - Acknowledgment: We used the BPE implementaition from Sennrich: subword-nmt https://github.com/rsennrich/subword-nmt

### Steps
- Run the Preprocessing Script: `./assignments/03/preprocess_data_BPE.sh {merge operations} {vocab threshold}`
- This will automatically create the corresponding prepared and preprocessed folder within en-fr/A3
- Then we can train the model with: `python train.py --data {path} --source-lang fr --target-lang en --save-dir {path}`
- Following this we then translate:  `python translate.py --data {path} --dicts {path} --checkpoint-path {path} --output {path}`
- We then have to clean the output with the new postprocess script -Example: `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/tiny/500_50/translations.txt ./assignments/03/translations_BPE/tiny/500_50/translations_clean.txt`
- Afterwards we have to postprocess again with the standard approach: `bash scripts/postprocess.sh path/to/output/file/model/translations path/to/postprocessed/model/translations/file en`
- Finally we can compute the BLEU score: `cat path/to/postprocessed/model/translations/file | sacrebleu path/to/raw/target/test/file`

## Our Experiments
To figure out a good amount of merge operations, we decided to first run a few tests on the tiny data set.
### TINY
#### Merge Operations 100, Vocabulary Threshold 50 (Tiny)
Commands
- `./assignments/03/preprocess_data_BPE.sh 100 50`
- `python train.py --data data/en-fr/A3/prepared_100_50 --source-lang fr --target-lang en --save-dir assignments/03/checkpoints_BPE/tiny/100_50 --train-on-tiny`
- `python translate.py --data data/en-fr/A3/prepared_100_50 --dicts data/en-fr/A3/prepared_100_50 --checkpoint-path assignments/03/checkpoints_BPE/tiny/100_50/checkpoint_best.pt --output assignments/03/translations_BPE/tiny/100_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/tiny/100_50/translations.txt ./assignments/03/translations_BPE/tiny/100_50/translations_clean.txt`
- `bash scripts/postprocess.sh assignments/03/translations_BPE/tiny/100_50/translations_clean.txt assignments/03/translations_BPE/tiny/100_50/translations_ready.txt en`
- `cat assignments/03/translations_BPE/tiny/100_50/translations_ready.txt | sacrebleu data/en-fr/raw/test.en`

Results
- `INFO: Loaded a source dictionary (fr) with 251 words`
- `INFO: Loaded a target dictionary (en) with 222 words`
- `INFO: Built a model with 339486 parameters`
- `INFO: Epoch 026: loss 2.077 | lr 0.0003 | num_tokens 21.22 | batch_size 1 | grad_norm 81.83 | clip 1`
- `INFO: Epoch 026: valid_loss 2.81 | num_tokens 20.9 | batch_size 500 | valid_perplexity 16.7`
- `{
 "name": "BLEU",
 "score": 0.6,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.0.0",
 "verbose_score": "15.4/1.1/0.2/0.0 (BP = 1.000 ratio = 1.800 hyp_len = 7004 ref_len = 3892)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.0.0"
}`

#### Merge Operations 500, Vocabulary Threshold 50 (Tiny)
Commands
- `./assignments/03/preprocess_data_BPE.sh 500 50`
- `python train.py --data data/en-fr/A3/prepared_500_50 --source-lang fr --target-lang en --save-dir assignments/03/checkpoints_BPE/tiny/500_50 --train-on-tiny`
- `python translate.py --data data/en-fr/A3/prepared_500_50 --dicts data/en-fr/A3/prepared_500_50 --checkpoint-path assignments/03/checkpoints_BPE/tiny/500_50/checkpoint_best.pt --output assignments/03/translations_BPE/tiny/500_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/tiny/500_50/translations.txt ./assignments/03/translations_BPE/tiny/500_50/translations_clean.txt`
- `bash scripts/postprocess.sh assignments/03/translations_BPE/tiny/500_50/translations_clean.txt assignments/03/translations_BPE/tiny/500_50/translations_ready.txt en`
- `cat assignments/03/translations_BPE/tiny/500_50/translations_ready.txt | sacrebleu data/en-fr/raw/test.en`

Results
- `INFO: Loaded a source dictionary (fr) with 573 words`
- `INFO: Loaded a target dictionary (en) with 541 words`
- `INFO: Built a model with 421661 parameters`
- `INFO: Epoch 027: loss 2.599 | lr 0.0003 | num_tokens 15.2 | batch_size 1 | grad_norm 74.05 | clip 1` 
- `INFO: Epoch 027: valid_loss 3.92 | num_tokens 15 | batch_size 500 | valid_perplexity 50.2`
- `{
 "name": "BLEU",
 "score": 1.1,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.0.0",
 "verbose_score": "18.7/1.7/0.4/0.1 (BP = 1.000 ratio = 1.497 hyp_len = 5825 ref_len = 3892)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.0.0"
}`

#### Merge Operations 1000, Vocabulary Threshold 50 (Tiny)
Commands
- `./assignments/03/preprocess_data_BPE.sh 1000 50`
- `python train.py --data data/en-fr/A3/prepared_1000_50 --source-lang fr --target-lang en --save-dir assignments/03/checkpoints_BPE/tiny/1000_50 --train-on-tiny`
- `python translate.py --data data/en-fr/A3/prepared_1000_50 --dicts data/en-fr/A3/prepared_1000_50 --checkpoint-path assignments/03/checkpoints_BPE/tiny/1000_50/checkpoint_best.pt --output assignments/03/translations_BPE/tiny/1000_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/tiny/1000_50/translations.txt ./assignments/03/translations_BPE/tiny/1000_50/translations_clean.txt`
- `bash scripts/postprocess.sh assignments/03/translations_BPE/tiny/1000_50/translations_clean.txt assignments/03/translations_BPE/tiny/1000_50/translations_ready.txt en`
- `cat assignments/03/translations_BPE/tiny/1000_50/translations_ready.txt | sacrebleu data/en-fr/raw/test.en`

Results
- `INFO: Loaded a source dictionary (fr) with 921 words`
- `INFO: Loaded a target dictionary (en) with 903 words`
- `INFO: Built a model with 513799 parameters`
- `INFO: Epoch 020: loss 3.115 | lr 0.0003 | num_tokens 13.84 | batch_size 1 | grad_norm 60.32 | clip 1`
- `INFO: Epoch 020: valid_loss 4.35 | num_tokens 13.6 | batch_size 500 | valid_perplexity 77.1`
- `{
 "name": "BLEU",
 "score": 0.4,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.0.0",
 "verbose_score": "15.5/1.1/0.2/0.0 (BP = 1.000 ratio = 1.714 hyp_len = 6671 ref_len = 3892)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.0.0"
}`

### Full
Given that we achieved the highest BLEU score with 500 merge operations on the tiny data set, we decide to use that to train the full data set.
Sadly the results were not as good, so we decide to reduce the number of merge operations by 100. This yielded better results,
prompting us to reduce the number of steps once more to 300. Results of these 3 steps can be seen below.
#### Merge Operations 500, Vocabulary Threshold 50 (FULL)
Commands
- `python train.py --data data/en-fr/A3/prepared_500_50 --source-lang fr --target-lang en --save-dir assignments/03/checkpoints_BPE/full/500_50`
- `python translate.py --data data/en-fr/A3/prepared_500_50 --dicts data/en-fr/A3/prepared_500_50 --checkpoint-path assignments/03/checkpoints_BPE/full/500_50/checkpoint_best.pt --output assignments/03/translations_BPE/full/500_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/full/500_50/translations ./assignments/03/translations_BPE/full/500_50/translations_clean.txt`
- `bash scripts/postprocess.sh assignments/03/translations_BPE/full/500_50/translations_clean.txt assignments/03/translations_BPE/full/500_50/translations_ready.txt en`
- `cat assignments/03/translations_BPE/full/500_50/translations_ready.txt | sacrebleu data/en-fr/raw/test.en`

Results
- `INFO: Loaded a source dictionary (fr) with 573 words`
- `INFO: Loaded a target dictionary (en) with 541 words`
- `INFO: Built a model with 421661 parameters`
- `: Epoch 038: loss 1.816 | lr 0.0003 | num_tokens 15.24 | batch_size 1 | grad_norm 68.94 | clip 0.9997`
- `INFO: Epoch 038: valid_loss 2.08 | num_tokens 15 | batch_size 500 | valid_perplexity 8`
- `INFO: No validation set improvements observed for 3 epochs. Early stop!`
- `{
 "name": "BLEU",
 "score": 15.1,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.0.0",
 "verbose_score": "42.8/19.5/10.7/5.8 (BP = 1.000 ratio = 1.311 hyp_len = 5103 ref_len = 3892)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.0.0"
}`

#### Merge Operations 400, Vocabulary Threshold 50 (FULL)
Commands
- `python train.py --data data/en-fr/A3/prepared_400_50 --source-lang fr --target-lang en --save-dir assignments/03/checkpoints_BPE/full/400_50`
- `python translate.py --data data/en-fr/A3/prepared_400_50 --dicts data/en-fr/A3/prepared_500_50 --checkpoint-path assignments/03/checkpoints_BPE/full/400_50/checkpoint_best.pt --output assignments/03/translations_BPE/full/400_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/full/400_50/translations ./assignments/03/translations_BPE/full/400_50/translations_clean.txt`
- `bash scripts/postprocess.sh assignments/03/translations_BPE/full/400_50/translations_clean.txt assignments/03/translations_BPE/full/400_50/translations_ready.txt en`
- `cat assignments/03/translations_BPE/full/400_50/translations_ready.txt | sacrebleu data/en-fr/raw/test.en`

Results
- `INFO: Loaded a source dictionary (fr) with 496 words`
- `INFO: Loaded a target dictionary (en) with 465 words`
- `INFO: Built a model with 402065 parameters`
- `INFO: Epoch 061: loss 1.624 | lr 0.0003 | num_tokens 15.92 | batch_size 1 | grad_norm 68.24 | clip 0.9994`
- `INFO: Epoch 061: valid_loss 1.85 | num_tokens 15.7 | batch_size 500 | valid_perplexity 6.37`
- `INFO: No validation set improvements observed for 3 epochs. Early stop!`
- `{
 "name": "BLEU",
 "score": 18.4,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.0.0",
 "verbose_score": "47.5/23.3/13.3/7.7 (BP = 1.000 ratio = 1.216 hyp_len = 4733 ref_len = 3892)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.0.0"
}`

#### Merge Operations 300, Vocabulary Threshold 50 (FULL)
Commands
- `python train.py --data data/en-fr/A3/prepared_300_50 --source-lang fr --target-lang en --save-dir assignments/03/checkpoints_BPE/full/300_50`
- `python translate.py --data data/en-fr/A3/prepared_300_50 --dicts data/en-fr/A3/prepared_300_50 --checkpoint-path assignments/03/checkpoints_BPE/full/300_50/checkpoint_best.pt --output assignments/03/translations_BPE/full/300_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/full/300_50/translations ./assignments/03/translations_BPE/full/300_50/translations_clean.txt`
- `bash scripts/postprocess.sh assignments/03/translations_BPE/full/300_50/translations_clean.txt assignments/03/translations_BPE/full/300_50/translations_ready.txt en`
- `cat assignments/03/translations_BPE/full/300_50/translations_ready.txt | sacrebleu data/en-fr/raw/test.en`

Results
- `INFO: Loaded a source dictionary (fr) with 415 words`
- `INFO: Loaded a target dictionary (en) with 386 words`
- `INFO: Built a model with 381634 parameters`
- `INFO: Epoch 038: loss 1.729 | lr 0.0003 | num_tokens 16.77 | batch_size 1 | grad_norm 72.27 | clip 0.9999`
- `INFO: Epoch 038: valid_loss 1.99 | num_tokens 16.6 | batch_size 500 | valid_perplexity 7.35`
- `{
 "name": "BLEU",
 "score": 12.1,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.0.0",
 "verbose_score": "38.6/16.4/8.2/4.2 (BP = 1.000 ratio = 1.362 hyp_len = 5300 ref_len = 3892)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.0.0"
}`

