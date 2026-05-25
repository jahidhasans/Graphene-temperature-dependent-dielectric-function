# Graphene — Temperature-Dependent Dielectric Function

> **Data repository for the manuscript:**  
> *Effect of Temperature-Induced Dielectric Response on Radiative Heat Transfer in the Extreme Near-Field Regime*  
> J. H. Sagor *et al.* (under review, PRB, 2026)

This repository contains the input files, force-constant data, post-processing scripts, and representative output figures needed to reproduce the main results of the paper. The workflow computes the **anharmonic phonon dispersion** of graphene at finite temperature using the Anharmonic Special Displacement Method (ASDM) implemented in `ZG.x` (part of Quantum ESPRESSO / EPW), and then feeds the resulting thermally displaced configurations into **Yambo** to obtain the temperature-dependent dielectric function.

---

## Table of Contents

1. [Prerequisites and Background Knowledge](#1-prerequisites-and-background-knowledge)
2. [Software Requirements](#2-software-requirements)
3. [Repository Structure](#3-repository-structure)
4. [Workflow Overview](#4-workflow-overview)
   - [Step 1 — Ground-state DFT (QE)](#step-1--ground-state-dft-qe)
   - [Step 2 — Harmonic Force Constants (QE)](#step-2--harmonic-force-constants-qe)
   - [Step 3 — Anharmonic Phonons via ASDM (ZG.x)](#step-3--anharmonic-phonons-via-asdm-zgx)
   - [Step 4 — Non-self-consistent Calculation on ZG Configuration](#step-4--non-self-consistent-calculation-on-zg-configuration)
   - [Step 5 — Dielectric Function (Yambo)](#step-5--dielectric-function-yambo)
5. [Plotting and Post-processing](#6-plotting-and-post-processing)
6. [Important Caveats and Convergence Notes](#7-important-caveats-and-convergence-notes)
7. [Reference Documentation](#8-reference-documentation)
8. [Citation](#9-citation)

---

## 1. Prerequisites and Background Knowledge

This repository is intended for researchers with **basic familiarity with DFT calculations**. In particular, the reader is expected to be comfortable with:

- Running plane-wave DFT calculations with Quantum ESPRESSO (`pw.x`, `ph.x`, `q2r.x`, `matdyn.x`)
- The concept of phonon dispersion and interatomic force constants (IFCs)
- Submitting jobs on an HPC cluster (SLURM scripts are provided as templates)

A working knowledge of the Yambo many-body perturbation theory code is helpful for the dielectric function part (Step 5), but is not strictly required to follow Steps 1–4.

---

## 2. Software Requirements

| Software | Version used | Purpose |
|---|---|---|
| [Quantum ESPRESSO](https://www.quantum-espresso.org/) | v7.2 | SCF, NSCF, phonons, IFCs (`pw.x`, `ph.x`, `q2r.x`, `matdyn.x`) |
| EPW / ZG.x | compiled with QE v7.2 | Special displacement method & Anharmonic Special Displacement Method (`ZG.x`) |
| [Yambo](https://www.yambo-code.eu/) | v5.3 | Many-body Perturbation Theory |
| Python | ≥ 3.8 | Post-processing and plotting (`matplotlib`, `numpy`) |
| gnuplot *(optional)* | any recent version | Alternative plotting of phonon dispersions |

**Compiling ZG.x:** After compiling QE, `ZG.x` is built together with `make epw`. The executable is located at `$QE/EPW/ZG/src/ZG.x`. Refer to the [EPW documentation](https://docs.epw-code.org/doc/Installation.html) for compilation instructions.
---

## 3. Repository Structure

```
Graphene-temperature-dependent-dielectric-function/
│
├── QE_inputs/                        # Quantum ESPRESSO input files
│   ├── C.pbe-hgh.UPF                 # Carbon pseudopotential (PBE, HGH)
│   ├── ZG-scf_441_750.00K.in         # SCF input for ZG configuration at 750 K
│   ├── ZG-nscf_441_750.00K.in        # NSCF input (coarse grid)
│   ├── ZG-nscf_441_750.00K_shifted_grid.in  # NSCF input (shifted grid for Yambo)
│   └── gr_run_script.slurm           # Example SLURM job script
│
├── Anharmonic_force_constants/       # A-SDM iteration data at 750 K
│   ├── gr.441all.fc                  # Harmonic IFCs (4×4×1 q-grid)
│   ├── FORCE_CONSTANTS_750.00K_iter_0{1..4}      # Raw IFCs per iteration
│   ├── FORCE_CONSTANTS_sym_750.00K_iter_0{1..4}  # Symmetrized IFCs per iteration
│   ├── 750.00K_iter_0{1..4}.fc       # IFCs in q2r.x format (input for next iteration)
│   ├── ZG_1.in / ZG_2.in             # ZG.x input files for ASDM iterations
│   ├── ZG-scf_441_750.00K.in         # SCF input for the initial ZG configuration
│   ├── ZG-scf_750.00K_iter_01.in     # SCF input for finite-difference displacements
│   ├── gr_01_441.freq / gr_04_441.freq          # Phonon frequencies (iter 1 and 4)
│   ├── gr_01_441.freq.gp / gr_04_441.freq.gp   # gnuplot-ready frequency data
│   ├── matdyn_02.in                  # matdyn.x input for iteration 2 dispersion
│   └── all_scf_run.slurm             # SLURM script for running all finite-difference SCFs
│
├── Phonon_dispersion/                # Output figures
│   ├── Graphene_Anharmonic_Phonon_Dispersion.png   # Anharmonic dispersion at 1200 K
│   └── Graphene_Phonon_Dispersion_colored.png      # Colored comparison plot
│
├── Scripts/                          # Post-processing and plotting
│   ├── anharmonic_harmonic_phonon_dispersion.py    # Main dispersion plotting script
│   ├── plot_phonon_dispersion.py     # Auxiliary plotting utilities
│   ├── harmonic_MK.txt               # Harmonic phonon data along M–K path
│   ├── 1200K_anharmonic_MKp.txt      # Anharmonic phonon data at 1200 K
│   ├── Experimental_MK               # Experimental reference data
│   └── gr.441all.fc                  # Copy of harmonic IFCs for scripts
│
└── Yambo/                            # Yambo inputs and helper scripts
    ├── yambo_epsilon_input.in        # Main Yambo input for dielectric function ε(ω,q,T)
    ├── yambo_alpha_input.in          # Yambo input for polarizability α(ω,q,T)
    ├── double_grid_mapping.in        # Double-grid (fine k-grid) mapping input
    ├── r_setup                       # Yambo setup/initialization file
    ├── Double_grid_yambo_run.slurm   # SLURM script for double-grid Yambo run
    ├── gr_automation_all_momentum_vectors.slurm  # SLURM for looping over q-vectors
    ├── extract_im_real_epsilon_from_output_folder.sh  # Extract ε₁, ε₂ from outputs
    ├── organize_all_q_files.sh       # Organize output by q-point
    └── q_files_counter.sh            # Check how many q-point calculations finished
```

---

## 4. Workflow Overview

The overall pipeline is illustrated below. Each step builds on the output of the previous one.

```
pw.x (SCF)  →  ph.x + q2r.x (IFCs)  →  ZG.x SDM/ASDM loop  →  pw.x (NSCF on ZG config)  →  Yambo (ε,q,T)
```

### Step 1 — Ground-state DFT (QE)

Run a self-consistent field (SCF) calculation for graphene using the input file in `QE_inputs/ZG-scf_441_750.00K.in`.

```bash
mpirun -np <N> pw.x -nk <nk> < ZG-scf_441_750.00K.in > ZG-scf_441_750.00K.out
```

**Key parameters used in this work:**
- Exchange-correlation: PBE
- Pseudopotential: `C.pbe-hgh.UPF` (HGH norm-conserving, provided in `QE_inputs/`)
- k-point mesh: 4×4×1 (coarse grid for ZG; a shifted/finer grid is used for Yambo — see `ZG-nscf_441_750.00K_shifted_grid.in`)
- Kinetic energy cutoff: see input file

> ⚠️ **Convergence note:** The cutoff energies and k-point meshes used here were converged for the specific pseudopotential provided. **If you use a different pseudopotential, you must redo the convergence study** for both the wavefunction cutoff (`ecutwfc`) and the charge density cutoff (`ecutrho`), as well as the k-point sampling. For 2D materials like graphene, the vacuum layer thickness between periodic images must also be converged to prevent spurious interlayer interactions. The same applies if you want to apply this workflow to a different material.

---

### Step 2 — Harmonic Force Constants (QE)

The harmonic interatomic force constants (IFCs) are the starting point for the ASDM. They are obtained by running `ph.x` on a 4×4×1 q-point grid, followed by `q2r.x` to Fourier-transform to real space.

The resulting harmonic IFC file is `Anharmonic_force_constants/gr.441all.fc`.

If you already have converged harmonic IFCs for graphene (e.g., from a previous DFPT calculation), you can skip `ph.x` and feed your `.fc` file directly into the ASDM loop below. Make sure the q-grid is dense enough to reproduce the correct phonon dispersion before proceeding.

---

### Step 3 — Anharmonic Phonons via ASDM (ZG.x)

This is the central step. The ASDM self-consistently updates the IFCs by iterating between:
1. Generating a ZG special displacement configuration at temperature *T*
2. Running finite-difference SCF calculations on the displaced configuration
3. Extracting updated IFCs from the calculated forces
4. Mixing old and new IFCs and repeating

All data for **T = 750 K** and **4 iterations** are provided in `Anharmonic_force_constants/`. The workflow for one iteration is:

**3a. Generate ZG configuration and finite-difference inputs:**
```bash
ZG.x < ZG_1.in > ZG_1.out
# This generates ZG-scf_750.00K_iter_01_XXXX.in files
```

**3b. Run all finite-difference SCF calculations:**

The SLURM script `all_scf_run.slurm` loops over all displaced configurations and submits them. Adapt the paths and the number of cores to your cluster. Each individual SCF run is short (seconds to a few minutes for graphene), but there can be many (typically `6 × N_atoms × 2` displacements).

```bash
sbatch all_scf_run.slurm
```

**3c. Read forces and update IFCs:**
```bash
ZG.x < ZG_2.in > ZG_2.out
# This reads all fd_forces/ output files and writes 750.00K_iter_01.fc
```

**3d. Obtain the phonon dispersion for this iteration:**
```bash
matdyn.x < matdyn_02.in > matdyn_02.out
```

**Repeat** steps 3a–3d, replacing `iter_01` with `iter_02`, `iter_03`, etc., and updating the `flfrc` flag to point to the `.fc` file from the previous iteration. Convergence is typically checked by comparing the phonon dispersion across iterations (see `Phonon_dispersion/` for the converged result at 1200 K) or by tracking the Frobenius norm of the leading IFC matrix block.

> **Note on set A q-points:** The flag `incl_qA = .true.` is used here (graphene is a 2D material and the 4×4×1 supercell is used). This is appropriate because the supercell is large enough that the gauge-freedom error is small. For smaller supercells, setting `incl_qA = .false.` is recommended to avoid artefacts from degenerate modes at zone-boundary q-points. See the EPW documentation and Phys. Rev. Research 2, 013357 (2020) for details.

> ⚠️ **Convergence note:** The number of A-SDM iterations required to converge depends on the system and the starting IFCs. Four iterations were sufficient for graphene at 750 K, but you should always check convergence explicitly. Plotting the Frobenius norm of the self-consistent IFC matrix as a function of iterations (as described in the EPW documentation, Exercise 3) is a reliable convergence criterion.

---

### Step 4 — Non-self-consistent Calculation on ZG Configuration

Once the converged ZG configuration is obtained (from the last A-SDM iteration), a non-self-consistent (NSCF) calculation is performed to generate the Kohn-Sham wavefunctions and eigenvalues on a suitable k-point grid for Yambo.

```bash
# Coarse grid (for direct use with Yambo)
mpirun -np <N> pw.x -nk <nk> < ZG-nscf_441_750.00K.in > ZG-nscf_441_750.00K.out

# Shifted/fine grid (for double-grid integration in Yambo)
mpirun -np <N> pw.x -nk <nk> < ZG-nscf_441_750.00K_shifted_grid.in > ZG-nscf_441_750.00K_shifted_grid.out
```

Both input files are in `QE_inputs/`. After these runs, convert the QE output to Yambo format using `p2y` (part of the Yambo suite).

> **Note:** For 2D materials like graphene, the vacuum region in the supercell introduces spurious interactions between periodic images. A truncation of the Coulomb interaction is essential in the Yambo calculation (see `yambo_epsilon_input.in`).

---

### Step 5 — Dielectric Function (Yambo)

The dielectric function ε(ω) is computed with Yambo using the wavefunctions and eigenvalues from Step 4. All Yambo input files are in `Yambo/`.

**5a. Initialize Yambo:**
```bash
yambo -i -V all   # or use the r_setup file provided
```

**5b. Run the dielectric function calculation:**

Because graphene requires summing over many q-points in the Brillouin zone, the calculation is automated over all momentum-transfer vectors using:

```bash
sbatch gr_automation_all_momentum_vectors.slurm
```

This script loops over all q-vectors and submits individual Yambo jobs. The inputs `yambo_epsilon_input.in` (imaginary part of ε) and `yambo_alpha_input.in` (polarizability) are used here.

**5c. Double-grid integration:**

To improve convergence of the Brillouin zone integration with a manageable coarse grid, a double-grid (fine k-grid mapped onto the coarse grid) approach is used:

```bash
yambo < double_grid_mapping.in
sbatch Double_grid_yambo_run.slurm
```

**5d. Post-processing:**

After all q-point jobs finish, use the helper scripts to collect results:

```bash
bash q_files_counter.sh          # Check completion status
bash organize_all_q_files.sh     # Organize outputs by q-point
bash extract_im_real_epsilon_from_output_folder.sh  # Extract ε₁(ω) and ε₂(ω)
```

> ⚠️ **Convergence note:** The number of empty bands, the size of the response function matrix (`NGsBlkXd` in Yambo), the k-point density, and the energy cutoff for the polarizability all require convergence tests. The parameters in the provided input files were converged for the pseudopotential and geometry used in this work. If you change the pseudopotential, cell parameters, or target a different material, **these parameters must be re-converged**.

---

## 5. Plotting and Post-processing

Python scripts for reproducing the phonon dispersion figures in the paper are in `Scripts/`:

```bash
cd Scripts/
python anharmonic_harmonic_phonon_dispersion.py
```

This script reads the frequency data files (`harmonic_MK.txt`, `1200K_anharmonic_MKp.txt`) and the experimental reference (`Experimental_MK`) and produces the comparison plot. Output figures are also provided in `Phonon_dispersion/`.

---

## 6. Important Caveats and Convergence Notes

A summary of the parameters that require careful convergence testing is given below. The values used in this work were sufficient for our specific setup; **they are not guaranteed to be transferable without verification.**

| Parameter | Where to check | Comment |
|---|---|---|
| `ecutwfc` (wavefunction cutoff) | `QE_inputs/*.in` | Must be re-converged for different pseudopotentials |
| k-point mesh density | `QE_inputs/*.in` | Coarser grids are used for ZG/ASDM; finer grids for Yambo |
| Supercell size for ASDM | `ZG_1.in` (`dim1, dim2, dim3`) | Larger supercells give more accurate ZG configurations; always check size convergence |
| Number of ASDM iterations | `ZG_1.in`, `ZG_2.in` | Converge by comparing phonon dispersions across iterations |
| Number of empty bands (Yambo) | `yambo_epsilon_input.in` | Affects optical spectra and dielectric function |
| Yambo k-point grid | `double_grid_mapping.in` | Double-grid helps but coarse + fine grid density must be checked |
| `NGsBlkXd` (Yambo response matrix size) | `yambo_epsilon_input.in` | Controls completeness of the dielectric response |

**On pseudopotentials:** This work uses the HGH norm-conserving pseudopotential for carbon (`C.pbe-hgh.UPF`). If you use a different pseudopotential (e.g., ONCV, PAW), the energy cutoffs and possibly the k-point grids will need to be re-optimized. The phonon dispersion should be benchmarked against literature before proceeding to the A-SDM step.

**On temperature:** The A-SDM data provided here are for **T = 750 K** (4 iterations). The phonon dispersion figure in `Phonon_dispersion/` shows results extended to **T = 1200 K**. To reproduce results at a different temperature, repeat Step 3 with the desired `T` value in the ZG input files.

---

## 7. Reference Documentation

The A-SDM method and ZG.x code are described in detail in the following papers. If you use this data or workflow, please also cite them:

- M. Zacharias and F. Giustino, *Phys. Rev. Research* **2**, 013357 (2020) 
- M. Zacharias and F. Giustino, *Phys. Rev. B* **94**, 075125 (2016)
- M. Zacharias *et al.*, *Phys. Rev. B* **108**, 035155 (2023) — Anharmonic SDM (ASDM)

---

## 8. Citation

If you use these files or adapt this workflow, please cite:

```
J. H. Sagor et al., "Effect of Temperature-Induced Dielectric Response on Radiative Heat Transfer in the Extreme Near-Field Regime", (under review, PRB, 2026).

J. H. Sagor, Graphene-temperature-dependent-dielectric-function, GitHub repository (2026),
https://github.com/jahidhasans/Graphene-temperature-dependent-dielectric-function
```

---

*For questions about the data or workflow, please open an issue in this repository.*
