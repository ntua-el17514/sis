#!/bin/bash

#SBATCH --job-name=run
#SBATCH --output=/users/pa23/goumas/nfloros/quarter_socket_workloads/logs/runs/run.%j.out
#SBATCH --error=/users/pa23/goumas/nfloros/quarter_socket_workloads/logs/runs/run.%j.err
#SBATCH --cpus-per-task=1
#SBATCH --account=pa220401
#SBATCH --exclusive

module purge

module load gnu/8
module load intel/18
module load intelmpi/2018

DBG=""
I_DBG=""

if $DEBUG; then
    DBG="_dbg"
    I_DBG="-genv I_MPI_DEBUG=+5"
fi
IFS=: read -r h m s <<< "$TIME"
walltime=$((10#$h * 3600 + 10#$m * 60 + 10#$s))

IFS='_' read -r -a apps_array <<< "$APPS_ARRAY"
n_apps=${#apps_array[@]}
if (( n_apps == 0 )); then
    echo "No apps parsed from apps_joined='$APPS_ARRAY'" >&2
    exit
fi

# Source the function to create the machine files
if [[ "${POLICY}" == "dense" ]];then
	source policies/dense.sh
else
	# Default
	source policies/maxnodes.sh
fi

export NPB_TIMER_FLAG=on

NAS_PATH="/users/pa23/goumas/nfloros/NAS-Benchmarks/NPB3.4.2/NPB3.4-MPI/bin/" 
LOG_PATH="/users/pa23/goumas/nfloros/quarter_socket_workloads/logs${DBG}/${CASE}"

mkdir -p $LOG_PATH

max_app=${apps_array[${#apps_array[@]}-1]}
max=$(awk -F. '{print $3}' <<< "$max_app")

nodes=($(scontrol show hostname $SLURM_NODELIST))

# First remove all the machine files in the path
find "${LOG_PATH}" -maxdepth 1 -name 'nodelist*' -exec rm {} \;
# Then remove the pipe lock file
find  "${LOG_PATH}" -maxdepth 1 -name 'pipe' -exec rm {} \;
# Then create the machine files for each app
create_nodelist_files "${LOG_PATH}" "$CORES" "$APPS_ARRAY" "${nodes[@]}"

declare -a app_name app_class app_procs app_copies
for (( i=0; i<n_apps; i++ )); do
    IFS='.' read -r app_name[i] app_class[i] app_procs[i] app_copies[i] <<< "${apps_array[i]}"
    # validate
    if ! [[ "${app_procs[i]}" =~ ^[0-9]+$ ]] || ! [[ "${app_copies[i]}" =~ ^[0-9]+$ ]]; then
        echo "Malformed app entry: '${apps_array[i]}'. Expected PROGRAM.CLASS.PROCS.COPIES with numeric PROCS and COPIES." >&2
        return 1
    fi
done
# Current slot combinations. Left array is socket 0, right array is socket 1
# A = [2 2 2] [3 3 3]
# B = [2 2 2] [3 3 3]
# C = [3 3 3] [2 2 2]
# D = [3 3 3] [2 2 2] 
exclude_list=(0,1,4-12,16-19 0-3,7-15,18,19 0-6,10-17 2-9,13-19)
for (( i=0; i<n_apps; i++ )); do
	for (( c=0; c < app_copies[i] ; c++))
	{
		while [ ! -f "$LOG_PATH/pipe" ]; do
			copy=$(( c + 1))
			local_name=${app_name[i]}.${app_class[i]}.${app_procs[i]}-${i}.${copy}
			
			app_start=$(date +%s)
			mpirun ${I_DBG} -genv I_MPI_PIN_PROCESSOR_EXCLUDE_LIST="${exclude_list[i]}" -genv I_MPI_PIN_PROCESSOR_LIST allcores -machinefile ${LOG_PATH}/nodelist.${app_name[i]}.${app_class[i]}.${app_procs[i]}-${i}.${copy} -np ${app_procs[i]} ${NAS_PATH}/${app_name[i]}.${app_class[i]}.x 1>> ${LOG_PATH}/${local_name}.out
			app_end=$(date +%s)
			
			difference=$(( app_end - app_start ))
			echo "DATE of ${local_name} in seconds: $difference" 1>> $LOG_PATH/${local_name}.out
		done
	} &
done
sleep $walltime
touch ${LOG_PATH}/pipe
