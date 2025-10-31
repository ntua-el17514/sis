# Pick version of Slurm to install, currently available edition is 16.05
version="16.05"

########## EDIT THESE PARAMETERS ###########
# Set certificate names
cert_name="cert-floros-slurm.pem"
key_name="private_key.pem"
pkey_name="public_key.pem"
password="ENTER-YOUR-PASS-HERE"
# Pick your home directory
base_dir="$HOME/$USER"
home_dir="$HOME/$USER/slurm-install/$version"
# Set job queue path
job_queue_filepath=${base_dir%/}/job_queue.txt
# Based on underlying system
sys_cpus="20"
sockets="2"
cores_per_socket="10"
threads_per_core="1"
real_mem="57344"
partition_name="compute"
max_mem_per_node="57344"
#Execution variables
errpath="${base_dir%/}/nfloros/jobs/v-slurm-%j.err" # Job error path
outpath="${base_dir%/}/nfloros/jobs/v-slurm-%j.out" # Job output path
nodes_count=5 #insert the desired count of nodes
time="0-00:05:00" #insert the time to timeout (walltime)
mem_per_cpu=1000
# Add any other SLURM variables here
#MPI
mpirun_path="/apps/compilers/intel/18.0.4/impi/2018.4.274/intel64/bin/mpirun"
############################################
