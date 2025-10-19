#!/bin/bash -l

function find_max {
    # Find max in a list of four integers

    [[ $# -ne 5 ]] || { echo "Warning: find_max() requires exactly 4 arguments." >&2; return 1; }
    local max_val=$1
    shift
    for num in "$@"; do
        [[ "$num" =~ ^-?[0-9]+$ ]] || { echo "Error: '$num' is not an integer." >&2; return 1; }
        (( num > max_val )) && max_val="$num"
    done
    echo "$max_val" # Print the final maximum value
}

function find_min {
    # Find max in a list of four integers

    [[ $# -ne 5 ]] || { echo "Warning: find_min() requires exactly 4 arguments." >&2; return 1; }
    local min_val=$1
    shift
    for num in "$@"; do
        [[ "$num" =~ ^-?[0-9]+$ ]] || { echo "Error: '$num' is not an integer." >&2; return 1; }
        (( num < min_val )) && min_val="$num"
    done
    echo "$min_val" # Print the final maximum value
}

function sort_apps {
    [[ $# -ne 5 ]] || { echo "Warning: sort_apps() requires exactly 4 arguments." >&2; return 1; }
    local app1=$1
    local app2=$2
    local app3=$3
    local app4=$4
    printf "%s\n" "$@" | sort -t '.' -k3,3n
}
