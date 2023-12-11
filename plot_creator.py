from sacrebleu.metrics import BLEU
import numpy as np
import matplotlib.pyplot as plt

'''This script has been written to plot the BLEU-Score of the translations generated using beam search.'''

# We define the variables, these values were given by the command that was provided with this task

beam_sizes = ['10', '15', '25']
bleu_scores = [22.2, 22.1, 21.4]
brevity_penalty = [1.000, 0.949, 0.790]

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
ax.set_ylim([0, 1.5])

plt.show()
