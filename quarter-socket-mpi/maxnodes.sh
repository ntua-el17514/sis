#!/usr/bin/env bash
set -euo pipefail

# create_nodelist_files
#
# Usage:
# create_nodelist_files <path> <qnc> <apps_joined> <host1> [host2 ...]
#
# - path: directory to write nodelist files (created if missing)
# - qnc: quarter-node cores (e.g. 5)
# - apps_joined: underscore-separated "PROGRAM.CLASS.PROCS.COPIES" entries
# - remaining args: hostnames (slurm nodenames) to use for placement
#
# Writes files: ${path}/nodelist.<app_idx>.<copy_idx>  and node-layout.<node_idx> for debug.

####################### NOTE TO SELF #######################
# There will always be an underutilized node if processes  #
# are multiples of 2. That happens because 2^n has only a  #
# prime factor (2) whilst an ARIS socket contains 20 cores #
# and 20 has 2 prime factors 2 and 5, and 5 is not a prime #
# factor of 2^n.                                           #
############################################################
function create_nodelist_files {
local path=$1
local qnc=$2
local apps_joined=$3
shift 3

# hosts
local hostnames=( "$@" )
local host_count=${#hostnames[@]}
if (( host_count == 0 )); then
    echo "create_nodelist_files: no hostnames provided" >&2
    return 1
fi

mkdir -p "$path"

# parse apps
IFS='_' read -r -a apps_array <<< "$apps_joined"
local n_apps=${#apps_array[@]}
if (( n_apps == 0 )); then
    echo "No apps parsed from apps_joined='$apps_joined'" >&2
    return 1
fi

# decode each app entry into arrays: name, class, procs, copies
declare -a app_name app_class app_procs app_copies
local i
for (( i=0; i<n_apps; i++ )); do
    IFS='.' read -r app_name[i] app_class[i] app_procs[i] app_copies[i] <<< "${apps_array[i]}"
    # validate
    if ! [[ "${app_procs[i]}" =~ ^[0-9]+$ ]] || ! [[ "${app_copies[i]}" =~ ^[0-9]+$ ]]; then
        echo "Malformed app entry: '${apps_array[i]}'. Expected PROGRAM.CLASS.PROCS.COPIES with numeric PROCS and COPIES." >&2
        return 1
    fi
done



# Slots_per_node is 4 (four copies per node).
local slots_per_node=4

# validate qnc
if ! [[ "$qnc" =~ ^[0-9]+$ ]] || (( qnc <= 0 )); then
    echo "Invalid qnc (must be positive integer): '$qnc'" >&2
    return 1
fi

# Prepare per-copy files and clear any previous ones
for (( i=0; i<n_apps; i++ )); do
    for (( c=0; c<app_copies[i]; c++ )); do
        copy=$(( c + 1))
        : > "${path}/nodelist.${app_name[i]}.${app_class[i]}.${app_procs[i]}-${i}.${copy}"
    done
done

# For each app and for each copy, allocate app_procs processes
for (( i=0; i<n_apps; i++ )); do
    local need_per_copy=$(( app_procs[i]))
    local node_idx=0
    for (( c=0; c<app_copies[i]; c++ )); do
        local remaining_for_copy=$need_per_copy
        while (( remaining_for_copy > 0 )); do
            local host="${hostnames[ node_idx % host_count ]}"

            # assign up to qnc cores from this slot (may be partial on last slot)
            local assign_cores=$(( remaining_for_copy < qnc ? remaining_for_copy : qnc ))

            # append to the per-copy machine file
            copy=$(( c + 1 ))
            printf '%s:%d\n' "$host" "$assign_cores" >> "${path}/nodelist.${app_name[i]}.${app_class[i]}.${app_procs[i]}-${i}.${copy}"

            # decrement remaining and advance slot
            remaining_for_copy=$(( remaining_for_copy - assign_cores ))
            node_idx=$(( node_idx + 1 ))

            # safety guard
            if (( node_idx > 10000000 )); then
                echo "create_nodelist_files: aborting after too many slots (possible bug)" >&2
                return 1
            fi
        done
        # this copy finished
    done
done

echo "create_nodelist_files: created per-copy machine files under $path (no socket splitting)."
return 0
}
