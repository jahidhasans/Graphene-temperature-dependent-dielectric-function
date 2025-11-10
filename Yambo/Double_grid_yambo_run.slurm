#!/bin/bash
# FILENAME: gr.slurm
#SBATCH -A MCH240098 # Allocation name	
#SBATCH --nodes=1        # Total # of nodes 
#SBATCH --ntasks-per-node=32         # number of tasks per node
#SBATCH --time=2-00:00:00   # Total run time limit (hh:mm:ss)
#SBATCH --mem-per-cpu=30gb   # Job memory request
#SBATCH -J 300K_gryambo    # Job name
#SBATCH -o out.txt     # Name of stdout output file
#SBATCH -e err.txt     # Name of stderr error file
#SBATCH -p highmem    # Queue (partition) name
#SBATCH --mail-user=md.sagor@maine.edu 
#SBATCH --mail-type=all   # Send email to above address at begin and end of job

ulimit -l unlimited
module load gcc/11.2.0 openmpi/4.1.6


export PATH=/anvil/projects/x-mch240098/software_installation/qe-7.4.1/bin:$PATH
export PATH=/anvil/projects/x-mch240098/software_installation/yambo-5.3.0-git/bin:$PATH



cd out/ZG-300.00K-gr_300K.save/

echo 'p2y is running'
srun p2y 
echo 'Alhamdulillah p2y done, yambo is running'
srun yambo

mv S** r** /anvil/scratch/x-msagor/Bismillah_Hasan/Quantum_Espresso/Graphene/Graphehe_final_final/Anharmonic/300K/yambo/
 
echo 'Alhamdulillah done'


