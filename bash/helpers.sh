generate_slurm_conf (){
	./ environment-variables.sh
    major=$1
    if (( major <= 16 )); then
	echo "ControlMachine=<some-dynamically-allocated-node>
	AuthType=auth/slurm
	CacheGroups=0
	CryptoType=crypto/openssl
	JobCredentialPrivateKey=${home_dir%/}/etc/${key_name}
	JobCredentialPublicCertificate=${home_dir%/}/etc/${pkey_name}
	EnforcePartLimits=YES
	KillOnBadExit=1
	LaunchType=launch/slurm
	MpiDefault=pmi2
	ProctrackType=proctrack/linuxproc
	PropagateResourceLimitsExcept=CPU,NPROC
	ReturnToService=1
	SlurmctldPidFile=${home_dir%/}/var/slurm/slurmctld.pid
	SlurmctldPort=50001
	SlurmdPidFile=${home_dir%/}/var/slurm/slurmd.pid
	SlurmdPort=50002
	SlurmdSpoolDir=${home_dir%/}/var/spool/slurmd
	SlurmUser=${USER}
	SlurmdUser=${USER}
	StateSaveLocation=${home_dir%/}/var/spool/slurm
	SwitchType=switch/none
	TaskPlugin=task/none
	InactiveLimit=0
	KillWait=30
	MinJobAge=300
	SlurmctldTimeout=120
	SlurmdTimeout=300
	Waittime=0
	#
	#
	# SCHEDULING
	DefMemPerCPU=2800
	FastSchedule=1
	MaxMemPerCPU=2800
	SchedulerType=sched/backfill
	SelectType=select/cons_res
	SelectTypeParameters=CR_Core_Memory
	#
	#
	# JOB PRIORITY
	PriorityFlags=FAIR_TREE
	PriorityType=priority/multifactor
	PriorityDecayHalfLife=0
	PriorityCalcPeriod=300
	PriorityFavorSmall=NO
	PriorityMaxAge=30-00:00:00
	PriorityUsageResetPeriod=WEEKLY
	PriorityWeightAge=5000
	PriorityWeightJobSize=5000
	PriorityWeightFairshare=20000
	PriorityWeightPartition=0
	PriorityWeightQOS=0

	# LOGGING AND ACCOUNTING
	JobCompType=jobcomp/none
	SlurmctldDebug=info
	SlurmctldLogFile=${home_dir%/}/var/log/slurm/slurmctld.log
	SlurmdDebug=info
	SlurmdLogFile=${home_dir%/}/var/log/slurm/slurmd.log

	# COMPUTE NODES

	NodeName=node[001-002] CPUs=${sys_cpus} Sockets=${sockets} CoresPerSocket=${cores_per_socket} ThreadsPerCore=${threads_per_core} RealMemory=${real_mem} State=UNKNOWN" > ${base_dir%/}/slurm.conf.template.$version

	# Create cgroup.conf

	echo "# CGROUPS CONFIGURATION
	CgroupMountpoint=${home_dir%/}/sys/fs/cgroup
	ConstrainCores=no
	ConstrainRAMSpace=no" > ${base_dir%/}/cgroup.conf


    elif (( major == 25 )); then
	echo "SlurmctldHost=<some-dynamically-allocated-node>
	ClusterName=aris
	DisableRootJobs=NO
	EnforcePartLimits=YES
	MaxJobId=67043328
	GresTypes=gpu
	JobSubmitPlugins=lua
	KillOnBadExit=1
	LaunchType=launch/slurm
	MpiDefault=pmix
	ProctrackType=proctrack/cgroup
	PropagateResourceLimits=CORE
	PropagateResourceLimitsExcept=CPU,NPROC,NOFILE,STACK
	ReturnToService=1
	SlurmctldPidFile=${home_dir%/}/var/slurm/slurmctld.pid
	SlurmctldPort=50001
	SlurmdPidFile=${home_dir%/}/var/slurm/slurmd.pid
	SlurmdPort=50002
	SlurmdSpoolDir=${home_dir%/}/var/spool/slurmd
	SlurmdParameters=l3cache_as_socket
	SlurmUser=$USER
	StateSaveLocation=${home_dir%/}/var/spool/slurm
	SwitchType=switch/none
	TaskPlugin=task/cgroup,task/affinity
	InactiveLimit=0
	KillWait=30
	MinJobAge=300
	SlurmctldTimeout=120
	SlurmdTimeout=300
	Waittime=0
	DefMemPerCPU=3968
	SchedulerType=sched/backfill
	SelectType=select/cons_tres
	SelectTypeParameters=CR_Core_Memory
	PriorityFlags=FAIR_TREE
	PriorityType=priority/multifactor
	PriorityDecayHalfLife=0
	PriorityCalcPeriod=300
	PriorityFavorSmall=NO
	PriorityMaxAge=15-00:00:00
	PriorityUsageResetPeriod=WEEKLY
	PriorityWeightAge=5000
	PriorityWeightFairshare=20000
	PriorityWeightJobSize=2000
	PriorityWeightPartition=0
	PriorityWeightQOS=0
	AccountingStorageEnforce=limits
	AccountingStorageHost=$USER
	AccountingStorageType=accounting_storage/none
	AccountingStorageTRES=gres/gpu,gres/gpu:1g.10gb,gres/gpu:2g.20gb,gres/gpu:3g.40gb,gres/gpu:a100,gres/gpumem,gres/gpuutil
	JobCompHost=$USER
	JobCompLoc=/var/log/slurm/job_completions
	JobCompUser=$USER
	JobAcctGatherFrequency=30
	JobAcctGatherType=jobacct_gather/cgroup
	SlurmctldDebug=info
	SlurmctldLogFile=${home_dir%/}/var/log/slurm/slurmctld.log
	SlurmdDebug=quiet
	SlurmdLogFile=${home_dir%/}/var/log/slurm/slurmd.log
	AcctGatherEnergyType=acct_gather_energy/ipmi
	AcctGatherInterconnectType=acct_gather_interconnect/ofed
	NodeName=m[01-48] CPUs=128 Sockets=2 CoresPerSocket=64 ThreadsPerCore=1 RealMemory=507904 State=UNKNOWN
	PartitionName=compute Nodes=m[01-48] Default=YES MaxTime=48:00:00 MaxMemPerNode=507904 State=DOWN" > ${base_dir%/}/slurm.conf.template.$version
    echo "# CGROUPS CONFIGURATION
        CgroupMountpoint=${home_dir%/}/sys/fs/cgroup
        ConstrainCores=no
        ConstrainRAMSpace=no" > ${base_dir%/}/cgroup.conf

    elif (( major == 21 )); then
	echo "ControlMachine=slurmctld
	ClusterName=v-slurm
	ControlAddr=slurmctld
	SlurmUser=slurm
	SlurmctldPort=50001
	SlurmdPort=50002
	AuthType=auth/munge
	StateSaveLocation=${home_dir%/}/var/lib/slurmd
	SlurmdSpoolDir=${home_dir%/}/var/spool/slurmd
	SwitchType=switch/none
	MpiDefault=intelmpi
	SlurmctldPidFile=${home_dir%/}/var/run/slurmd/slurmctld.pid
	SlurmdPidFile=${home_dir%/}/var/run/slurmd/slurmd.pid
	ProctrackType=proctrack/linuxproc
	ReturnToService=0
	SlurmctldTimeout=300
	SlurmdTimeout=300
	InactiveLimit=0
	MinJobAge=300
	KillWait=30
	Waittime=0
	SchedulerType=sched/backfill
	SelectType=select/cons_res
	SelectTypeParameters=CR_CPU_Memory
	FastSchedule=1
	SlurmctldDebug=3
	SlurmctldLogFile=${home_dir%/}/var/log/slurm/slurmctld.log
	SlurmdDebug=3
	SlurmdLogFile=${home_dir%/}/var/log/slurm/slurmd.log
	JobCompType=jobcomp/filetxt
	JobCompLoc=${home_dir%/}/var/log/slurm/jobcomp.log
	JobAcctGatherType=jobacct_gather/linux
	JobAcctGatherFrequency=30
	NodeName=m[01-48] CPUs=128 Sockets=2 CoresPerSocket=64 ThreadsPerCore=1 RealMemory=507904 State=UNKNOWN
	PartitionName=compute Nodes=m[01-48] Default=YES MaxTime=48:00:00 MaxMemPerNode=507904 State=DOWN" > ${base_dir%/}/slurm.conf.template
    echo "# CGROUPS CONFIGURATION
        CgroupMountpoint=${home_dir%/}/sys/fs/cgroup
        ConstrainCores=no
        ConstrainRAMSpace=no" > ${base_dir%/}/cgroup.conf

}

parse_nlist() {
    # If arguments of function different from 2 exit
    if [[ $# -ne 1 ]]; then
        echo "Function parse_nlist requires 1 arguments <nodelist>"
        exit 1
    fi
    # Extract how many chars on a range entry
    num_chars=$(echo "$1" | cut -d'[' -f 2 | cut -d']' -f 1 | cut -d'-' -f 2 | cut -d ',' -f 1 | wc -c) 
    num_chars=$(expr $num_chars - 1)
    hostchar=$(echo "$1" | cut -d'[' -f1)
    range=$(echo "$1" | cut -d'[' -f2 | cut -d']' -f1)
    IFS=, read -r -a parts <<< "$range"
    for i in "${!parts[@]}"; do
        if [[ ${parts[$i]} == *-* ]]; then
            start_node="$(echo ${parts[$i]} | cut -d'-' -f1)"
            end_node="$(echo ${parts[$i]} | cut -d'-' -f2)"
            if [[ $num_chars -eq 3 ]]; then
                printf -v start_node "%03i" $(( 10#$start_node ))
                printf -v end_node "%03i" $(( 10#$end_node ))
            else
                printf -v start_node "%02i" $(( 10#$start_node ))
                printf -v end_node "%02i" $(( 10#$end_node ))
            fi
            parts[$i]="${start_node}-${end_node}"
        else
            node=${parts[$i]}
            if [[ $num_chars -eq 3 ]]; then
                printf -v node "%03i" $(( 10#$node ))
            else
                printf -v node "%02i" $(( 10#$node ))
            fi
            parts[$i]=$node
        fi
    done
    part1=${parts[0]}
    if [[ $part1 == *-* ]]; then
        start_node=$(echo $part1 | cut -d'-' -f1)
        end_node=$(echo $part1 | cut -d'-' -f2)
        if [[ $(expr $end_node - $start_node) -eq 1 ]]; then
            parts[0]=$end_node
        else
            start_node=$(echo "$(expr $start_node + 1)")
            if [[ $num_chars -eq 3 ]]; then
                printf -v start_node "%03i" $(( 10#$start_node ))
            else
                printf -v start_node "%02i" $(( 10#$start_node ))
            fi
            parts[0]="${start_node}-${end_node}"
        fi
    else
        parts=( "${parts[@]/$part1}" )
    fi
    echo "$hostchar[$(echo ${parts[@]} | sed 's/ /,/g')]"
}

## get_first_node_old_bash: parses node list
## Takes 1 argument: the part of nodelist
## which is delimited with '[' and '-'
## Returns the starting node of the nodelist
get_first_node_old_bash () {
    hostchar=$(echo "$1" | cut -d'[' -f1)
    range=$(echo "$1" | cut -d'[' -f2 | cut -d']' -f1)
    IFS=, read -r -a parts <<< "$range"
    if [[ $parts[0] == *-* ]]; then
        node=$(echo $parts[0] | cut -d '-' -f1 )
        echo "$hostchar$node"
    elif [[ $parts == $hostchar ]]; then
        echo "$hostchar"
    else 
        echo "$hostchar$parts"
    fi
}

## get_start_number: parses node list
## Takes 1 argument: the part of nodelist
## which is delimited with commas
## Returns the starting node of the nodelist
get_start_number() {
    input_string="$1"
    regex="^([^[]+)\[([0-9]+)-[0-9]+\]$"

    if [[ $input_string =~ $regex ]]; then
        some_name="${BASH_REMATCH[1]}"
        start_number="${BASH_REMATCH[2]}"
        result="${some_name}${start_number}"
        echo "$result"
    else
        echo "Invalid input format"
    fi
}

## check2nodes: parses node list and cpus
## Takes 3 arguments: the part of nodelist
## which is delimited with commas and the
## corresponding cpus of that part of the nodelist
## and the index of the nodelist
## Returns the number of nodes along with the
## cpus for that part of the nodelistt
## if index is 1, then the first node is left out

check2_nodes(){
    # If arguments of function different from 2 exit
    if [[ $# -ne 3 ]]; then
        echo "Function check2_nodes requires 3 arguments <nodelist> <cpus> <index>"
        exit 1
    fi
    # If nodelist is empty exit
    if [[ -z $1 ]]; then
        echo "Nodelist is empty"
        exit 1
    fi
    # If cpus is empty exit
    if [[ -z $2 ]]; then
        echo "CPUs is empty"
        exit 1
    fi
    local cpus=$(echo $2 | cut -d'(' -f1)

    if [[ $3 -eq 1 ]]; then
        if [[ $1 == *[* ]]; then
            hostchar=$(echo "$1" | cut -d'[' -f1)
            start_node=$(echo "$1" | cut -d'[' -f2 | cut -d'-' -f1)
            end_node=$(echo "$1" | cut -d'-' -f2 | cut -d']' -f1)
            if [[ $(expr $end_node - $start_node) -eq 1 ]]; then
                printf -v end_node "%03d" "$end_node"
                echo "$hostchar$end_node $cpus"
            else
                start_node=$(echo "$(expr $start_node + 1)")
                printf -v start_node "%03d" "$start_node"
                printf -v end_node "%03d" "$end_node"
                echo "$hostchar[${start_node}-${end_node}] $cpus"
            fi
        else
            echo "control $cpus"
        fi
    else
        echo "$1 $cpus"
    fi
    
}
################### --END-- ###################
