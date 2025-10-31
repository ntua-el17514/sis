#!/bin/bash

# Find object code
version="16.05"
home_dir="$HOME/nfloros/slurm-install/$version/"
lib_dir="${home_dir}lib/slurm/"
so_files=$(find ${home_dir}slurm-*/src/plugins/ -type f -name "*.so")
cd ${home_dir}lib/slurm/

IFS=$'\n'
# Create symlinks for object code
for so_file in $so_files; do
    ln -s $lib_dir$so_file $(basename $so_file)
done