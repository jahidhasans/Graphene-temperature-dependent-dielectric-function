import numpy as np
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import matplotlib.ticker as ticker
import scienceplots

plt.style.use(['science', 'no-latex'])

# Load harmonic and experimental phonon dispersion data
harmonic_data = np.loadtxt("phonon_dispersion_gr/harmonic_MK.txt")
experimental_data = np.loadtxt("phonon_dispersion_gr/Experimental_MK")  # 2 columns

fig, ax = plt.subplots(figsize=(6.2, 4.5))

for i in range(6):
    ax.plot(harmonic_data[:, 0], harmonic_data[:, i + 1] * 1.2398e-4,
            lw=1.5, color=colors[i])

# Plot experimental data (red circles)
ax.plot(experimental_data[:, 0], experimental_data[:, 1] * 8.065610 * 1.2398e-4, 
        'o', label="Experiment", markersize=4, color="red")

# High-symmetry lines
for x in [0.5774, 0.9107, 1.5774]:
    ax.axvline(x=x, color='gray', linestyle='--', linewidth=0.8)

# Axis settings
ax.set_xlim(0, 1.5774)
ax.set_ylim(0.0005, 0.210766)
ax.set_yticks(np.linspace(0.005, 0.22, 5))
ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%.3f'))
ax.set_xticks([])
ax.set_ylabel("Energy [eV]", fontsize=16, fontweight='bold')
ax.set_xlabel("Wavevector", labelpad=18, fontsize=16, fontweight='bold')
ax.tick_params(axis='both', labelsize=14)

# High-symmetry point labels
ax.text(-0.02, -0.011, r'$\Gamma$', fontsize=16)
ax.text(0.5774 - 0.03, -0.011, 'M', fontsize=16)
ax.text(0.9107 - 0.02, -0.011, 'K', fontsize=16)
ax.text(1.5774 - 0.02, -0.011, r'$\Gamma$', fontsize=16)

solid_lines_handle = Line2D([0], [0], color='black', lw=2)  # single solid line sample
experiment_handle = Line2D([0], [0], color='red', marker='o', lw=0, markersize=5)

ax.legend(
    handles=[solid_lines_handle, experiment_handle],
    labels=["Present study (solid lines)", "Experiment"],
    fontsize=12, loc='upper center', frameon=False, ncol=1
)

fig.savefig("Graphene_Phonon_Dispersion_colored.png", dpi=600, bbox_inches='tight')
plt.show()
