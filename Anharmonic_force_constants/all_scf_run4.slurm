#!/bin/bash
# FILENAME: all_scf_run.slurm
#SBATCH -A MCH240098 # Allocation name	
#SBATCH --nodes=1       # Total # of nodes 
#SBATCH --ntasks=128    # Total # of MPI tasks
#SBATCH --time=4-00:00:00   # Total run time limit (hh:mm:ss)
#SBATCH -J 1200K_gr    # Job name
#SBATCH -o out.txt     # Name of stdout output file
#SBATCH -e err.txt     # Name of stderr error file
#SBATCH -p wholenode # Queue (partition) name
#SBATCH --mail-user=md.sagor@maine.edu 
#SBATCH--mail-type=all   # Send email to above address at begin and end of job

ulimit -l unlimited
module load gcc/11.2.0 openmpi/4.1.6
export PATH=/anvil/projects/x-mch240098/software_installation/qe-7.4.1/bin:$PATH

file=ZG-scf_750.00K_iter_01
mkdir -p fd_forces/
for i in {0145..0192}; do
   mkdir -p $i
   cd $i
   cp ../C.pbe-hgh.UPF .
   if [ ! -f "../${file}_${i}.in" ]; then
       echo "Warning: ${file}_${i}.in not found, skipping..."
       cd ../
       continue
   fi
   mv ../"$file"_"$i".in .
   srun pw.x < "$file"_"$i".in > "$file"_"$i".out
   echo "Alhamdulillah ${i}/64 is done"
   mv "$file"_"$i".out ../fd_forces/.
   rm C.pbe-hgh.UPF
   cd ../
done

#for file in fd_forces/ZG-scf_750.00K_iter_01_*.out; do
    #sed -i 's/"//' "$file"
#done
