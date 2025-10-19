#!/bin/bash

# Create certificates
cert_name="cert-floros-slurm.pem"
key_name="v-slurm-key.pem"
touch {$cert_name,$key_name}
# Store them in $home_dir/etc/
home_dir=.
mkdir --parents $home_dir/etc
cp {$cert_name,$key_name} $home_dir/etc/

slurm_conf_tempalte="ControlMachine=node001
AuthType=auth/none
CacheGroups=0
CryptoType=crypto/openssl
JobCredentialPrivateKey=${home_dir}/etc/${key_name}
JobCredentialPublicCertificate=${home_dir}/etc/${cert_name}
EnforcePartLimits=YES
# GresTypes=gpu,mic
KillOnBadExit=1
LaunchType=launch/slurm
MpiDefault=pmi2
ProctrackType=proctrack/linuxproc
PropagateResourceLimitsExcept=CPU,NPROC
ReturnToService=1
SlurmctldPidFile=/users/pa23/goumas/nfloros/slurm-install/16.05/var/slurm/slurmctld.pid
SlurmctldPort=50001
SlurmdPidFile=/users/pa23/goumas/nfloros/slurm-install/16.05/var/slurm/slurmd.pid
SlurmdPort=50002
SlurmdSpoolDir=/users/pa23/goumas/nfloros/slurm-install/16.05/var/spool/slurmd
SlurmUser=goumas
SlurmdUser=goumas
#SrunEpilog=/users/slurm/scripts/SrunEpilog
#SrunProlog=/users/slurm/scripts/SrunProlog
StateSaveLocation=/users/pa23/goumas/nfloros/slurm-install/16.05/var/spool/slurm
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
# DefMemPerCPU=0
DefMemPerCPU=2800
FastSchedule=1
MaxMemPerCPU=2800
SchedulerType=sched/backfill
# SchedulerPort=7321
SelectType=select/cons_res
SelectTypeParameters=CR_Core_Memory
#
#
# JOB PRIORITY
PriorityFlags=FAIR_TREE
#PriorityType=priority/basic
PriorityType=priority/multifactor
#PriorityDecayHalfLife=24:00:00
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
# AccountingStorageHost=xcat1
# AccountingStorageType=accounting_storage/slurmdbd
# #AccountingStorageEnforce=limits
# AccountingStorageEnforce=safe
# #AccountingStorageType=accounting_storage/filetxt
# AccountingStoreJobComment=YES
# ClusterName=v_slurm
# JobCompHost=xcat1
# JobCompLoc=/var/log/slurm/job_completions
# JobCompPort=3306
# JobCompType=jobcomp/slurmdbd
JobCompType=jobcomp/none
# JobCompUser=slurm
# JobContainerType=job_container/none
# JobAcctGatherFrequency=30
# JobAcctGatherType=jobacct_gather/linux
# AcctGatherEnergyType=acct_gather_energy/ipmi
# AcctGatherInfinibandType=acct_gather_infiniband/ofed
# AcctGatherEnergyType=acct_gather_energy/none
# AcctGatherInfinibandType=acct_gather_infiniband/none
SlurmctldDebug=info
SlurmctldLogFile=/users/pa23/goumas/nfloros/slurm-install/16.05/var/log/slurm/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/users/pa23/goumas/nfloros/slurm-install/16.05/var/log/slurm/slurmd.log
#SlurmSchedLogFile=/users/pa23/goumas/nfloros/slurm-install/16.05/var/log/slurm/slurmd.log

# COMPUTE NODES
NodeName=node[001-002] CPUs=20 Sockets=2 CoresPerSocket=10 ThreadsPerCore=1 RealMemory=57344 State=UNKNOWN"

echo $slurm_conf_tempalte