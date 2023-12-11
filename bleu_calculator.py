from sacrebleu.metrics import BLEU
import numpy as np
import matplotlib.pyplot as plt

'''This script has been written to assess the BLEU-Score of the translations generated using beam search.'''

# defining variables
en_fr_reference = []

beam10 = []
beam15 = []
beam25 = []

# creating list with lists of sentences  We are not using alternatives in this case.

with open('data/en-fr/preprocessed/test.en') as reference:
    for line in reference:
        en_fr_reference.append(line)

# For the candidates, we also create a list of sentences per file.
with open("assignments/05/model_translation_beam10.txt") as beam10_txt:
    for line in beam10_txt:
        beam10.append(line)

with open("assignments/05/model_translation_beam15.txt") as beam15_txt:
    for line in beam15_txt:
        beam15.append(line)

with open("assignments/05/model_translation_beam25.txt") as beam25_txt:
    for line in beam25_txt:
        beam25.append(line)

bleu = BLEU()

out_10 = bleu.corpus_score(en_fr_reference, beam10)
out_15 = bleu.corpus_score(en_fr_reference, beam15)
out_25 = bleu.corpus_score(en_fr_reference, beam25)

print(out_10, out_15, out_25)

# As a little help, we have given the results in plain text below

'''BLEU = 2.23 5.3/2.9/1.7/1.0 (BP = 1.000 ratio = 9.500 hyp_len = 19 ref_len = 2) 
BLEU = 2.23 5.3/2.9/1.7/1.0 (BP = 1.000 ratio = 9.500 hyp_len = 19 ref_len = 2) 
BLEU = 2.65 10.5/2.9/1.7/1.0 (BP = 1.000 ratio = 9.500 hyp_len = 19 ref_len = 2)'''

# We create the plot now

# We define the variables
beam_sizes = ['10', '15', '25']
bleu_scores = [2.23, 2.23, 2.65]
brevity_penalty = [1.000, 1.000, 1.000]

# This section is added to be able to display bars next to each other
n = 3
r = np.arange(n)
width = 0.25

# Creating and labeling the plot
plt.bar(r, bleu_scores, color='b',
        width=width,
        label='BLEU-Score')

plt.xlabel("Beam Size")
plt.ylabel("BLEU-Score", color='b')
plt.title("BLEU-Score and Brevity Penalty by Beam Size")

# Adding a second y-axis
plt2 = plt.twinx()
plt2.bar(r + width, brevity_penalty, color='g',
        width=width,
        label='Brevity Penalty')

plt.ylabel('Brevity Penalty', color='g')
plt.xticks(r + width / 2, beam_sizes)

# Here, we artifically raise the numbers on the right y-axis, to make the resulting plot more readable
ax = plt.gca()
ax.set_ylim([0, 3])

plt.show()
