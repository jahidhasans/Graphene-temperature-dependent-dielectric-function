import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import matplotlib.ticker as ticker
import scienceplots

plt.style.use(['science', 'no-latex'])

# Load harmonic and experimental phonon dispersion data
harmonic_data = np.loadtxt("phonon_dispersion_gr/harmonic_MK.txt")
experimental_data = np.loadtxt("phonon_dispersion_gr/1200K_anharmonic_MKp.txt")  # 2 columns

fig, ax = plt.subplots(figsize=(6.2, 4.5))

for i in range(1, 7):  # columns 1-6 (excluding first column, wavevector)
    if i == 1:
        ax.plot(harmonic_data[:, 0], harmonic_data[:, i]*1.2398e-4, 
                lw=1.5, color='b', ls='--', label="Harmonic")  # dashed blue line
    else:
        ax.plot(harmonic_data[:, 0], harmonic_data[:, i]*1.2398e-4, 
                lw=1.5, color='b', ls='--')

# Plot anharmonic data (solid black)
for i in range(1, 7):
    if i == 1:
        ax.plot(experimental_data[:, 0], experimental_data[:, i]*1.2398e-4, 
                lw=1.5, color='k', label="Anharmonic")
    else:
        ax.plot(experimental_data[:, 0], experimental_data[:, i]*1.2398e-4, 
                lw=1.5, color='k')

# High-symmetry points vertical lines
for x in [0.5774, 0.9107, 1.5774]:
    ax.axvline(x=x, color='gray', linestyle='--', linewidth=0.8)

ax.set_xlim(0, 1.5774)
ax.set_ylim(0.0005, 0.210766)
ax.set_yticks(np.linspace(0.005, 0.22, 5))
ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%.3f'))
ax.set_xticks([])
ax.set_ylabel("Energy [eV]", fontsize=16, fontweight='bold')
ax.set_xlabel("Wavevector", labelpad=18, fontsize=16, fontweight='bold')
ax.tick_params(axis='both', labelsize=14)

# Add high-symmetry point labels
ax.text(0 - 0.02, -0.011, r'$\Gamma$', fontsize=16)
ax.text(0.5774 - 0.03, -0.011, 'M', fontsize=16)
ax.text(0.9107 - 0.02, -0.011, 'K', fontsize=16)
ax.text(1.5774 - 0.02, -0.011, r'$\Gamma$', fontsize=16)

ax.legend(
    fontsize=14,
    loc='upper right',
    frameon=False,
    ncol=1,
    columnspacing=1.2,
    handletextpad=0.3
)
ax.legend(
    fontsize=14,
    loc='lower center',
    bbox_to_anchor=(0.5, 0.97),  # move to above the inset
    frameon=False,
    ncol=2,
    columnspacing=1.6,
    handletextpad=0.1
)

# Save figure
fig.savefig("Graphene_Anharmonic_Phonon_Dispersion.png", dpi=600, bbox_inches='tight')

plt.show()
