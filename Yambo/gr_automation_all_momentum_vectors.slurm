#!/bin/bash
# FILENAME: gr.slurm
#SBATCH -A MCH240098 # Allocation name	
#SBATCH --nodes=1        # Total # of nodes 
#SBATCH --ntasks-per-node=32         # number of tasks per node
#SBATCH --time=2-00:00:00   # Total run time limit (hh:mm:ss)
#SBATCH --mem-per-cpu=30gb   # Job memory request
#SBATCH -J 750Kyambo_damptest    # Job name
#SBATCH -o outch.txt     # Name of stdout output file
#SBATCH -e errch.txt     # Name of stderr error file
#SBATCH -p highmem    # Queue (partition) name
#SBATCH --mail-user=md.sagor@maine.edu 
#SBATCH --mail-type=all   # Send email to above address at begin and end of job

ulimit -l unlimited
module load gcc/11.2.0 openmpi/4.1.6

export PATH=/anvil/projects/x-mch240098/software_installation/yambo-5.3.0-git/bin:$PATH


# Input and output file paths
input_file="yambo_eps_input.in"
mpi_dir="converged_750K"
mkdir -p $output_dir

# Define variables for the total range and step size
max_range=629
step_size=1

# Loop for ranges of QpntsRXd
for ((start=1; start<=max_range; start+=step_size)); do
    end=$((start + step_size - 1))
    if [ $end -gt $max_range ]; then
        end=$max_range
    fi
    
    modified_input_file="input_${start}_${end}.in"

    # Create a modified input file with dynamic QpntsRXd
    sed "/% QpntsRXd/,/%/c\% QpntsRXd\n    $start |  $end |\n%" $input_file > $modified_input_file

    # Run the job using the modified input file
    srun yambo -F $modified_input_file -J $mpi_dir -C "output_files/eps" 

    # Move output files to the output directory
    mv o-$mpi_dir.eps* $output_dir/
done




