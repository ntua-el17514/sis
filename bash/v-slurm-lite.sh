#!/bin/bash -l
#SBATCH --job-name=SlurmVirtualCluster
# Run prologue script
./prologue.sh

# Nodes for configuration and SiS sruns (have to agree with SBATCH options)
# total nodes - 1 (controller node)
n_slurmd=$(( NODES_COUNT - 1 ))
n_cpus=1
# Make helper functions available
. ./helpers.sh
. ./environment_variables.sh
major="${version%%.*}"
if (( major == 16 ));then
    # Avoid state errors from previous executions
    rm -r ${home_dir%/}/var/spool/{slurmd,slurm}
    mkdir --parents ${home_dir%/}{/spool/{slurm,slurmd},/var/{run,log,log/slurm,slurm,spool/{slurm,slurmd}}}
    #touch ${home_dir%/}/var/run/slurmctld.pid ${home_dir%/}/var/spool/slurm/{node_state,job_state.old,node_state.old,resv_state,resv_state.old,job_state,trigger_state,trigger_state.old}
    chmod 755 -R ${home_dir%/}
fi
# Older versions of SLURM uses this runtime variable
nodelist=$SLURM_NODELIST
cpus=$SLURM_JOB_CPUS_PER_NODE

cnodes_txt=''

# Parse the nodelist
cnodes_list=$(parse_nlist "$nodelist")
# Get the control machine (slurmctld will run here)
control_machine=$(get_first_node_old_bash "$nodelist")

# We have to create a new slurm.conf file for each execution
# Creates a slurm.conf template that contains generic cluster information
# that is changing per execution 
cnodes_txt+="NodeName=${cnodes_list} CPUs=${sys_cpus} Sockets=${sockets} CoresPerSocket=${cores_per_socket} ThreadsPerCore=${threads_per_core} RealMemory=${real_mem}\n"
cnodes_txt+="PartitionName=${partition_name} Nodes=${cnodes_list} Default=YES MaxMemPerNode=${max_mem_per_node} DefaultTime=24:00:00"
config_text=$(head -n -1 ${home_dir%/}/etc/slurm.conf.template | tail -n +2 )

major="${version%%.*}"
if (( major <= 16 )); then
	mkdir --parents ${home_dir%/}{/spool/{slurm,slurmd},/var/{run,log,log/slurm,slurm,spool/{slurm,slurmd}}}
	touch ${home_dir%/}/var/run/slurmctld.pid ${home_dir%/}/var/spool/slurm/{node_state,job_state,trigger_state}
	chmod 755 -R ${home_dir%/}

    # Create slurm.conf for older versions
    config_text=$(echo -e "ControlMachine=${control_machine}\n$config_text\n$cnodes_txt")

elif (( major == 25 ));then

    # Create slurm.conf for newer versions
	config_text=$(echo -e "SlurmctldHost=${control_machine}\n$config_text\n$cnodes_txt")
fi

echo -e "$config_text" > ${home_dir%/}/etc/slurm.conf
# Setup slurmctld
# -N, --nodes, request -N nodes allocated for the job
# -n, --ntasks, specify the -n tasks to run, -c changes this defualt
# -c, --cpus-per-task, request that -c cpus be allocated per process

# SLURM controller is ought to run in single machine - Hard coded options
srun -N 1 -n 1 -c 1 --nodelist=${control_machine} ${home_dir%/}/slurm-slurm-*/src/slurmctld/slurmctld -f ${home_dir%/}/etc/slurm.conf -Dvvvv &
sleep 10
# Setup slurmd
srun -N $n_slurmd -n $n_slurmd -c $n_cpus --nodelist=${cnodes_list} ${home_dir%/}/slurm-slurm-*/src/slurmd/slurmd/slurmd -f ${home_dir%/}/etc/slurm.conf -Dvvvv & 
sleep 10
(
    unset SLURM_JOBID SLURM_JOB_ID SLURM_NPROCS

    ${home_dir%/}/slurm-slurm-*/src/scontrol/scontrol show nodes

    env -i \
    PATH=${home_dir%/}/slurm-slurm-*/src \
    HOME=$HOME \
    SLURM_NODELIST=$cnodes_list \
    SLURM_CLUSTER_NAME="v_slurm" \
    USER=$USER \
    SHELL=/bin/bash \
    SIS_CONFIG_PATH=${home_dir%/}/etc/ \
    SLURM_CONF=${home_dir%/}/etc/slurm.conf \
    # Stalls main script until all jobs are finished.
    while (( $(${home_dir%/}/slurm-slurm-*/src/squeue/squeue -u goumas | wc -l) > 2 )); do
        ${home_dir%/}/slurm-slurm-*/src/scancel/scancel --user=$USER
        sleep 1
    done
    grep -Ev '^(#|$)' job_queue.txt | while read -r path delay; do
        ${home_dir%/}/slurm-slurm-*/src/sbatch/sbatch --nodes=$n_slurmd --time=$SBATCH_TIMELIMIT $path
        sleep $delay
    done
)
./epilogue.sh
