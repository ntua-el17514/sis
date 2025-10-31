#!/bin/bash
## Resource Request
#SBATCH --job-name=SlurmVirtualCluster
#SBATCH --output=/users/pa23/goumas/nfloros/jobs/slurm-install-%j.out
#SBATCH --error=/users/pa23/goumas/nfloros/jobs/slurm-install-%j.err
#SBATCH --time=0-00:05:00
#SBATCH --nodes=3
##SBATCH --ntasks=4
##SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=1000

module purge
module load gnu/8
module load intel/18
module load intelmpi/2018
env

srun echo "$hostname"