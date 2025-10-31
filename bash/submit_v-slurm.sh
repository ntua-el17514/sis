#!/bin/bash
. ./environment_variables.sh
sbatch --nodes=$nodes_count --time=$time --partition=$partition_name --time=$time --mem-per-cpu=$mem_per_cpu --error=$errpath --output=$outpath --export=NODES_COUNT=$nodes_count v-slurm-lite.sh
