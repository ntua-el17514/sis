#!/bin/bash

#SBATCH --job-name=compact
#SBATCH --output=/users/pa23/goumas/nfloros/quarter_socket_workloads/logs/runs/compact.%j.out
#SBATCH --error=/users/pa23/goumas/nfloros/quarter_socket_workloads/logs/runs/compact.%j.err
#SBATCH --cpus-per-task=1
#SBATCH --account=pa220401
#SBATCH --exclusive
#SBATCH --nodes=4
#SBATCH --time=1-01:25:00

module load gnu/8
module load intel/18
module load intelmpi/2018
LOG_PATH="/users/pa23/goumas/nfloros/quarter_socket_workloads/logs"
nas=(ep cg bt ft mg lu sp is)

for prog in "${nas[@]}"; do
	mkdir -p $LOG_PATH/${prog}_compact/
	while [ ! -f "$LOG_PATH/${prog}_compact/pipe" ]; do
		mpirun -np 64 /users/pa23/goumas/nfloros/NAS-Benchmarks/NPB3.4.2/NPB3.4-MPI/bin/${prog}.D.x > $LOG_PATH/${prog}_compact/compact_${prog}.out
	done &
	sleep 600
	touch "$LOG_PATH/${prog}_compact/pipe"
done
