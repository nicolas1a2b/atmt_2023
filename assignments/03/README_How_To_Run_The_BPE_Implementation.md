# How to run the BPE implementation for A3
 - Authors: Nicolas Fazli Kohler & Eric Szabo Felix 
 - Acknowledgment: We used the BPE implementaition from Sennrich: subword-nmt https://github.com/rsennrich/subword-nmt

### Steps
Note: We also installed cuda to run it locally on our GPU:  
`pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`
`sudo apt-get update`
`sudo apt install nvidia-cuda-toolkit`
- Run the Preprocessing Script: `./assignments/03/preprocess_data_BPE.sh {merge operations} {vocab threshold}`
- This will automatically create the corresponding prepared and preprocessed folder within en-fr/A3
- Then we can train the model with: `python train.py --data {path} --source-lang fr --target-lang en --save-dir {path}`
- Following this we then translate:  `python translate.py --data {path} --dicts {path} --checkpoint-path {path} --output {path}`
- We then have to clean the output with the new postprocess script -Example: `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/tiny/500_50/translations.txt ./assignments/03/translations_BPE/tiny/500_50/translations_clean.txt`
- Lastly we calculate the BLEU score: ``
## Our Experiments
#### Merge Operations 500, Vocabulary Threshold 50 (Tiny)
Commands
- `./assignments/03/preprocess_data_BPE.sh 500 50`
- `python train.py --data data/en-fr/A3/prepared_500_50 --source-lang fr --target-lang en --save-dir assignments/checkpoints_BPE/tiny/500_50 --train-on-tiny`
- `python translate.py --data data/en-fr/A3/prepared_500_50 --dicts data/en-fr/A3/prepared_500_50 --checkpoint-path assignments/03/checkpoints_BPE/tiny/500_50/checkpoint_best.pt --output assignments/03/translations_BPE/tiny/500_50/translations`
- `./assignments/03/postprocessBPE.sh ./assignments/03/translations_BPE/tiny/500_50/translations.txt ./assignments/03/translations_BPE/tiny/500_50/translations_clean.txt`
Results
- `INFO: Epoch 027: valid_loss 3.92 | num_tokens 15 | batch_size 500 | valid_perplexity 50.2`
