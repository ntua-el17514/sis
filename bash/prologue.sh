#!/bin/bash

# Run HPC specific commands and more

# ARIS modules
module purge
module load gnu/8
module load intel/18
module load intelmpi/2018
module load python/3.9.18

# User custom code can be inserted below
