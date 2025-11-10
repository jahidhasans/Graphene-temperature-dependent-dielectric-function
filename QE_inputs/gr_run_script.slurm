#!/bin/bash
# FILENAME: gr.slurm
#SBATCH -A MCH240098 # Allocation name	
#SBATCH --nodes=1        # Total # of nodes 
#SBATCH --ntasks=128   # Total # of MPI tasks
#SBATCH --time=4-00:00:00   # Total run time limit (hh:mm:ss)
#SBATCH -J 750K_grnoshift   # Job name
#SBATCH -o out.txt     # Name of stdout output file
#SBATCH -e error.txt     # Name of stderr error file
#SBATCH -p shared    # Queue (partition) name
#SBATCH --mail-user=md.sagor@maine.edu 
#SBATCH --mail-type=all   # Send email to above address at begin and end of job

ulimit -l unlimited
module load gcc/11.2.0 openmpi/4.1.6


export PATH=/anvil/projects/x-mch240098/software_installation/qe-7.4.1/bin:$PATH


echo "SCF started at $(date)"
srun pw.x < ZG-scf_441_750.00K.in > ZG-scf_441_750.00K.out
echo "SCF finished at $(date)"

echo "NSCF started at $(date)"
srun pw.x < ZG-nscf_441_750.00K.in > ZG-nscf_441_750.00K.out
echo "NSCF finished at $(date)"


