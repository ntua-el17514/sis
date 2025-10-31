#!/bin/bash
cpus="72(x2),36"
parse_cpu_count() {
    if [[ $# -eq 0 ]]; then
        echo "No input provided - Parse of \$SLURM_JOB_NODELIST or
            \$SLURM_JOB_CPUS_PER_NODE returned no value."
        exit 1
    fi
    if [[ $# -gt 2 ]]; then
        echo "Too many arguments provided - Parse of \$SLURM_JOB_NODELIST or
            \$SLURM_JOB_CPUS_PER_NODE returned too many values."
        exit 1
    fi
    local input=$1
    local cpu_counts=()

    IFS=',' read -ra nodes <<< "$input"

    for node in "${nodes[@]}"; do
        cpu_count=$(echo "$node" | cut -d'(' -f1)
        cpu_counts+=("$cpu_count")
    done

    if [[ $# -eq 2 ]]; then
        local index=$2
        echo "${cpu_counts[$index]}"
    else
        echo "${cpu_counts[@]}"
    fi
}

echo "Test 1: 72(x2),36 get 72"
echo "$(parse_cpu_count "$cpus" "0")"
echo "Test 2: slurm.conf"
echo "NodeName=1 RealMemory=1000 CPUs=$(parse_cpu_count "$cpus" "1")"
echo "Test 3: 72(x2),36 get 36"
echo "$(parse_cpu_count "$cpus" "1")"
echo "Test 4: 72(x2),36 get all"
echo "$(parse_cpu_count "$cpus")"
echo "Test 5: More args"
echo "$(parse_cpu_count "$cpus" "1" "2")"
echo "Test 6: No args"
echo "$(parse_cpu_count)"