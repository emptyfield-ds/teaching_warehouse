import matplotlib.pyplot as plt
import seaborn as sns

# Load penguins dataset
penguins = sns.load_dataset("penguins")

# Create the plot
plt.figure(figsize=(6, 4))
sns.scatterplot(
    data=penguins,
    x="flipper_length_mm",
    y="body_mass_g",
    hue="species",
    alpha=0.7
)

plt.title("Penguin Flipper Length vs Body Mass")
plt.xlabel("Flipper Length (mm)")
plt.ylabel("Body Mass (g)")
plt.tight_layout()

# Save the figure
plt.savefig("/figures/penguins.png", dpi=300)
plt.close()