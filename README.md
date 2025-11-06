# Slurm-in-Slurm (SiS) & Quarter-Socket Workloads

## Overall Repository Architecture
Currently the repository contains 2 main components:
1. The [bash scripts and unit tests](/home/nf/Documents/Dissertation/dissertation-code/bash). Those consist of the main bash scripts to download and make the executables of the desired Slurm version, as well as the scripts to run workloads using the virtual Slurm installation, and
2. The [Quarter-socket experiments](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi) which include the scripts to test and run NAS Benchmarks on allocation of ¼-socket on ARIS supercomputer.

## Repository File Hierarchy

```
.
├── bash
|    ├── aris_boilerplate.sh
|    ├── environment_variables.sh
|    ├── epilogue.sh
|    ├── helpers.sh
|    ├── job_queue.txt
|    ├── prologue.sh
|    ├── v-slurm-lite.sh
|    ├── submit_v-slurm.sh
|    └── unit_tests
|
quarter-socket-mpi/
├── data
│   └── nas_quarter_socket.csv
├── find_max_min.sh
├── maxnodes.sh
├── run_compact.sh
├── run_cos.NAS_NAS.sh
├── submit_cmp.sh
└── submit_co.sh
```

## Slurm-in-Slurm (SiS): A tool for testing and using custom plugins in Slurm clusters
The following sub-sections contain information on the tool developed in this thesis and a hands-on example on how to deploy and run SiS

### Step-by-Step Example Usage

This section describes how to download and make your virtual SLURM cluster.

After downloading the git repo, the file hierarchy you ought to see under your download folder is the one described in [Repository File Hierarchy](#repository-file-hierarchy).

To continue the setup, enter the `bash` directory.

First of all, check the `environment_variables.sh` file and change any parameters that your execution environment requires. This file is responsible for storing paths and parameters your code will need. Although, thorough description of the variables is given within the files, we have attached a more detailed description here:
```bash
# Pick version of Slurm to install, currently uneditable
version="16.05"

########## EDIT THESE PARAMETERS ###########
# Set certificate names
cert_name="cert-floros-slurm.pem"                                                   
key_name="private_key.pem"                                                      # <----- Private and public keys are used for authentication 
pkey_name="public_key.pem"                                                      #        purposes from SLURM 16.05, when installing they are  
password="ENTER-YOUR-PASS-HERE"                                                 #        created by the boilerplate script using these names and 
# Pick your home directory                                                      #        password.
base_dir="$HOME/$USER"                                                          # <----- The base directory stores all code and scripts. By default
home_dir="$HOME/$USER/slurm-install/$version"                                   #        it is the path under your user. The home folder 
# Set job queue path                                                            #        stores all configuration and source code of SiS.
job_queue_filepath=${base_dir%/}/job_queue.txt                                  # <----- job_queue.txt stores paths of the scripts you want executed
# Hardware Specifications, based on underlying system                           #        by SiS. You can add delays between executions as well.
sys_cpus="20"                                                                   # <----- Hardware specification varibles. Be surre to give your 
sockets="2"                                                                     #        exact hardware specifications to SiS.
cores_per_socket="10"                                                           #
threads_per_core="1"                                                            #
real_mem="57344"                                                                #
partition_name="compute"                                                        #
max_mem_per_node="57344"                                                        #
#Execution variables (variables passed to sbatch)
errpath="${base_dir%/}/nfloros/jobs/v-slurm-%j.err"                             # <----- Job error path
outpath="${base_dir%/}/nfloros/jobs/v-slurm-%j.out"                             # <----- Job output path
nodes_count=5                                                                   # <----- Desired count of nodes
time="0-00:05:00"                                                               # <----- Time to timeout (walltime)
mem_per_cpu=1000                                                                # <----- Memory allocation of each CPU
# Add any other SLURM variables here
#MPI                                                                            #
mpirun_path="/apps/compilers/intel/18.0.4/impi/2018.4.274/intel64/bin/mpirun"   # <----- The mpirun executable. MPI has to be already installed in
############################################                                    #        your system
```

Then, run the `aris_boilerplate.sh` script. Use the `-i` option if it is the first time the script is executed, or `-c` option whenever changes to SLURM configuration (i.e. `slurm.conf` or similar files) are made. The installation will take some minutes, do not falter!

Depending on the version you have chosen in the `environment_variables.sh` file, the proper version will be downloaded. Currently SiS supports full operability and has been validated with version 16.05.11.1, but also supports proper installation of versions 21.08.6.1 and 25.05.1.1.

```CLI
./aris_boilerplate.sh
```

After the installation has finished you should be able to see a folder called `slurm-install` under the `$home_dir` path you have specified in the corresponding variable of your `environment_variables.sh`. In `$home_dir` one should also find the `.zip` source code containing the SLURM version installed, this file should **NOT** be deleted to use the `-c` option of the boilerplate script. The `$home_dir` folder contains the version of the installed SLURM, meaning it can also be configured to contain multiple SLURM installations to be used by SiS at any time.

After installation the following folder hierarchy should be visible under `slurm-install` (example for version 16.05.11.1):

```
slurm-install/
└── 16.05
    ├── etc
    ├── lib
    │   └── slurm
    ├── sbin
    ├── slurm-slurm-16-05-11-1
    │   ├── auxdir
    │   ├── contribs
    │   ├── doc
    │   ├── etc
    │   ├── slurm
    │   ├── src
    │   └── testsuite
    ├── spool
    │   ├── slurm
    │   └── slurmd
    ├── sys
    │   └── fs
    └── var
        ├── log
        ├── run
        ├── slurm
        └── spool

```

To initiate a SiS execution the user has to issue run the `submit_v-slurm.sh` script as follows:
1. Navigate to the installation directory (e.g. The directory containing the `submit_v-slurm.sh`) and
2. Execute `./submit_v-slurm.sh`
(or `/path-to-/submit_v-slurm.sh`)


The script will take care of the rest. The `submit_v-slurm.sh` acts as an intermediary script in order not to be forced to change multiple scripts at each execution. Whenever you want to change some Slurm or SiS parameter and/or path, just edit `environment_variables.sh` and you are done. Simple as that.

Moreover, a `prologue.sh` script can be used to integrate custom user code **BEFORE** SiS execution, for now it is used only to load the appropriate ARIS modules. Likewise, an `epilogue.sh` script is used for to integrate custom user code **AFTER** the SiS execution.

During SiS execution, the jobs submitted to SiS are given through the `job_queue.txt`. This is a simple text file that contains the paths to the jobs to be submitted to SiS in a tab-seperated format where the first entry of each line is the job path and the second entry is the interval until the next job submission. To avoid confusion the user is prompted to use full paths.

>**IMPORTANT NOTICE**: The `v-slurm-lite.sh` script can accept configurable `#SBATCH` options, these are used by SLURM, but are omitted from the bash interpreter. If they are set then they will overwrite the  and should agree with your hardware specifications and the specifications you have included in your `environment_variables.sh`.

Currently, `job_queue.txt` contains a path to simple scripts that validate SiS proper execution.

### Explanation of SLURM scripts

#### Environment variables
The [environment_variables.sh](https://github.com/cslab-ntua/sis/blob/main/bash/environment_variables.sh) script contains all variables used for pathmaking, parameter passing to downstream scripts (i.e. [boilerplate script](#boilerplate-script), [virtual SLURM script](#virtual-slurm-script) etc.) and system/hardware specific options.

#### Boilerplate script
The first script is the [boilerplate.sh](https://github.com/cslab-ntua/sis/blob/main/bash/aris_boilerplate.sh) script which is used to either download and make the SLURM executables in your preferred directory, or reconfigure your already installed SLURM directory.

OPTIONS
\-i, \--install \-     Used for 1st time installation. It will create all executables and keys used for installation and later configurations.
\-c, \--configure \-   After installing alternating your configuration files (e.g. slurm.conf) will only need the reconfiguration of the installation, rather than installing all of the software from the beginning.

The script does the following tasks:

1. Parses the Slurm version to install specified from the user in `environment_variables.sh`
2. Creates all necessary directories to host the source code and SiS functions
3. Creates an initial slurm.conf.template that is used in each SiS execution to generate a slurm.conf
4. Generates ssl keys used by SiS to authenticate the user (Slurm version 16)
5. Depending on if the `-i --install` option was used, it downloads the SLURM version and unpacks it before finally using `make` to compile the executables
6. It links dependencies to the systems libraries (Slurm version 16)

##### Things to consider

1. The boilerplate script currently allows for editing which Slurm version should be installed. This option should be edited manually within the `environment_variables.sh` file. The currently tested, working version of Slurm is 16.05.11.1.
2. It also creates the slurm.conf file. At the moment the user, ports and file hierarchy are created statically but could be altered within the `helpers.sh` script, although, we would advise against that if you are not an experienced Slurm system administrator, or do not have knowledge of the underlying cluster of machines you are instaling the SiS.
3. The script is configured specifically for the ARIS HPC cluster. That is important considering that it uses the currently available partitions and machines of ARIS.

#### Submit script

The [submit_v-slurm.sh](https://github.com/cslab-ntua/sis/blob/main/bash/submit_v-slurm.sh) is the script in charge of intermediating between the options set by the user in the [environment variables file](#environment-variables) and the [virtal cluster script](#virtual-slurm-script). Its only job is to export the variables to the sbatch script used to deploy SiS.

#### Virtual SLURM script

The [v-slurm-lite.sh](https://github.com/cslab-ntua/sis/blob/main/bash/v-slurm-lite.sh) is the script initiating SiS. The script is tasked with running checks to see any missing configuration files, parsing the current configuration of the outer SLURM job submitted and starting the slurmctld and slurmd daemons for SiS based on the outer's SLURM job configuration.

This script is:
1. Executing any user code on `prologue.sh`
2. Storing and the original allocation, in order to
3. Create a new `slurm.conf` on the spot for SiS
4. Launching the `slurmctld` and `slurmd` for SiS
5. Executing any scripts given in the `job_queue.txt` (by default simple Slurm commands) 
6. Execute custom user code with `epilogue.sh`

##### Things to consider

1. This script is configured for any Slurm version.
2. Its main purpose is to edit and reconfigure the virtual Slurm cluster each time a workload is executed to sync with the actual allocation of nodes the original Slurm system has allocated to a job.
![Concept Representation of Slurm-in-Slurm](https://github.com/ntua-el17514/dissertation-code/assets/115066332/83ed0225-46b0-4763-b45c-b3e2cc0c092c)

3. Within the script the number of machines asked can be edited depending on the job that is being run. Special care should be taken to make the necessary changes to the sbatch options in the beginning of the file as well.

#### Helper functions

In the `helpers.sh` script several *bash* functions are defined and then used to parse system and SLURM configuration. These custom functions mostly parse system specific information and probably will have to be altered if you port SiS on any other system than ARIS.

## ¼-socket Experiments

The 2nd part of this dissertation is the ¼-socket Experiments. The [quarter socket part](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi) of the repo dedicated in running NAS Benchmarks dedicating a quarter of the available CPUs of each socket. This leads to running 4 different benchmarks simulteanously on each run. The 8 total benchmark types can be combined in 70 different unordered sets to provide useful insights. For this dissertation all benchmarks have been of class D (more on bencmark classes on [NASA's webpage](https://www.nas.nasa.gov/software/npb.html)), and each one executed utilising 64 hardware threads.

The scripts of the repository consist of:
1. [`find_max_min.sh`](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/find_max_min.sh): A script of helper functions to find minimum and maximum of a list and sorting the applications based on threads requested.
2. [`maxnodes.sh`](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/maxnodes.sh): A script to calculate the allocation of nodes per benchmark and generate the nodelist file which is then used by MPI to properly assign threads/CPUs per application. A benchmark application will be copied until the 4 applications have equal threads.
3. [A submit script - `submit_cmp.sh`](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/submit_cmp.sh) and the [actual execution script - `run_compact.sh`](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/run_compact.sh) to get the times for compact (as in standalone) execution of a benchmark.
4. Finally, following the previous logic, [A submit script - `submit_co.sh`](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/submit_co.sh) and the [actual execution script - `run_cos.NAS_NAS.sh`](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/run_cos.NAS_NAS.sh) to get the times for co-execution of the NAS benchmarks. 

The raw data can be found in the [data directory](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/data) for validation and cross-examination reasons.

If you wish to compile the NAS benchmarks onto your own directory follow [these instructions](https://www.nas.nasa.gov/software/npb.html), otherwise, **replace LOG_PATH variable and mpirun paths in [compact](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/run_compact.sh) and/or [co-location](https://github.com/cslab-ntua/sis/blob/main/quarter-socket-mpi/run_cos.NAS_NAS.sh) scripts with your own path(s)**.
