#!/bin/bash
nlist="c[1-2]"
cpus="72(x2)"
host="c1"
cnodes_txt=""

## Takes 2 arguments: the part of nodelist
## which is delimited with commas and the
## corresponding cpus of that part of the nodelist
## Returns the number of cpus of the nodelist
check2_nodes(){
    # If arguments of function different from 2 exit
    if [[ $# -ne 3 ]]; then
        echo "Function check2_nodes requires 3 arguments <nodelist> <cpus> <host_found>"
        exit 1
    fi
    # If nodelist is empty exit
    if [[ -z $1 ]]; then
        echo "Nodelist is empty"
        exit 1
    fi
    # If cpus is empty exit
    if [[ -z $2 ]]; then
        echo "CPUs is empty"
        exit 1
    fi
    local cpus=$(echo $2 | cut -d'(' -f1)
    # If nodelist is not in the format of [x-y]
    # not enough nodes for virtual cluster. Exit
    hostchar=$(echo "${host}" | tr -cd '[:alpha:]')
    if [[ ! $1 =~ .*\[.*\].* ]] && [[ $hostchar == $(echo $1 | tr -cd '[:alpha:]') ]]; then
        echo "Only single node allocated. Exiting..."
        exit 1
    else
        cluster_char=$(echo "$1" | cut -d'[' -f1)
        # if cluster_char is NOT same as hostchar then return nodelist and cpus
        if [[ $cluster_char != $hostchar ]]; then
            echo "$1 $(echo "$2" | cut -d'(' -f1)"
        else
            compute_range=$(echo "$1" | cut -d'[' -f2 | cut -d ']' -f1)
            start_node=$(echo "$compute_range" | cut -d'-' -f1)
            end_node=$(echo "$compute_range" | cut -d'-' -f2)
            # CHANGE this line after testing
            hostnum=$(echo "${host}" | tr -cd '[:digit:]')
            case $hostnum in
                $start_node)
                    # Code for when hostnum is equal to start_node
                    if [[ $(expr $end_node - $hostnum) -eq 1 ]]; then
                        echo "$hostchar$(expr $hostnum + 1) $(echo "$2" | cut -d'(' -f1)"
                    else
                        echo "$hostchar[$(expr $hostnum + 1)-${end_node}] $(echo "$2" | cut -d'(' -f1)"
                    fi
                    ;;
                *)
                    if [[ $3 == '1' ]]; then
                        # Code for when hostnum is between start_node and end_node
                        echo "The first node in the nodelist was not allocated"
                        echo "Exiting..."
                        exit 1
                    else
                        echo "$1 $(echo "$2" | cut -d'(' -f1)"
                    fi
                    ;;
            esac
        fi
        
    fi
}

# echo "Test 1: 72(x2) get 72"
# echo "$(check2_nodes "$nlist" "$cpus" '0')"
# echo "Test 2: Single node"
# echo "$(check2_nodes "c1" "72" '0')"
# echo "Test 3: Different host"
# host="c2"
# echo "$(check2_nodes "$nlist" "$cpus" '0')"
# echo "Test 4: Different host single node"
# echo "$(check2_nodes "c2" "72" '0')"
# host="c1"
# echo "Test 5: slurm.conf"
# output=$(check2_nodes "$nlist" "$cpus" '0')
# echo "NodeName=$(echo ${output} | cut -d' ' -f 1) RealMemory=1000 CPUs=$(echo ${output} | cut -d' ' -f 2)"
# nlist="c[1-10]"
# cpus="72(x10)"
# echo "Test 6: 72x10 get 72"
# output=$(check2_nodes "$nlist" "$cpus" '0')
# echo "NodeName=$(echo ${output} | cut -d' ' -f 1) RealMemory=1000 CPUs=$(echo ${output} | cut -d' ' -f 2)"
# host="c19"
# nlist="c[19-32]"
# cpus="72(x14)"
# echo "Test 7: 72x14 get 72"
# output=$(check2_nodes "$nlist" "$cpus" '0')
# echo "NodeName=$(echo ${output} | cut -d' ' -f 1) RealMemory=1000 CPUs=$(echo ${output} | cut -d' ' -f 2)"
# nlist="c[19-32],c[1-10]"
# cpus="72(x14),32(x10)"
# echo "Test 8: 72x14 , 32x10 get full text"
# # $( echo $nlist | tr ' ' ',')
# index=1
# IFS=',' read -r -a nlist <<< "$nlist"
# for node in ${nlist[@]}; do
#     output=$(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")
#     cnodes_txt+="NodeName=$( echo ${output} | cut -d ' ' -f 1) RealMemory=${mem_per_cpu} CPUs=$(echo ${output} | cut -d' ' -f 2)"$'\n'
#     ((index++))
# done
# echo "$cnodes_txt"

echo "Test 9: 72x2 get c2 72"
cnodes_txt=""
nlist="c[1-2]"
cpus="72(x2)"
index=1
IFS=',' read -r -a nlist <<< "$nlist"
for node in ${nlist[@]}; do
    echo "Node: $node CPU: $(echo $cpus | cut -d' ' -f $index)"
    output=$(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")
    echo "$output"
    cnodes_txt+="NodeName=$( echo ${output} | cut -d ' ' -f 1) RealMemory=${mem_per_cpu} CPUs=$(echo ${output} | cut -d' ' -f 2)"$'\n'
    ((index++))
done
echo "$cnodes_txt"