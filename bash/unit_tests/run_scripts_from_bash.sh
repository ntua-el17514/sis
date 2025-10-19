#!/bin/bash
grep -v '^#' test_filehame.txt | while read -r path delay; do
    # sbatch ...
    sleep $delay
done
