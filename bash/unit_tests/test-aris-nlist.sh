#!/bin/bash
################### HELPER FUNCTIONS ###################

## get_start_number: parses node list
## Takes 1 argument: the part of nodelist
## which is delimited with commas
## Returns the starting node of the nodelist
get_start_number() {
    input_string="$1"
    regex="^([^[]+)\[([0-9]+)-[0-9]+\]$"

    if [[ $input_string =~ $regex ]]; then
        some_name="${BASH_REMATCH[1]}"
        start_number="${BASH_REMATCH[2]}"
        result="${some_name}${start_number}"
        echo "$result"
    else
        echo "Invalid input format"
    fi
}

## check2nodes: parses node list and cpus
## Takes 3 arguments: the part of nodelist
## which is delimited with commas and the
## corresponding cpus of that part of the nodelist
## and the index of the nodelist
## Returns the number of nodes along with the
## cpus for that part of the nodelistt
## if index is 1, then the first node is left out

check2_nodes(){
    # If arguments of function different from 2 exit
    if [[ $# -ne 3 ]]; then
        echo "Function check2_nodes requires 3 arguments <nodelist> <cpus> <index>"
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

    if [[ $3 -eq 1 ]]; then
        
        # nodes in the format node[1,5-10] or node[1-10,20-30]
        if [[ $1 == *[*,*] ]]; then
            hostchar=$(echo "$1" | cut -d'[' -f1)
            control_node=$(echo "$1" cut -d'[' -f2 | cut -d',' -f1)
            # If control node is in the format 1-10
            if [[ $control_node == *-* ]]; then
                start_node=$(echo $control_node | cut -d'-' -f1)
                end_node=$(echo $control_node | cut -d'-' -f2)
                # end_node of the first part of the nodelist
                # if control node is 1-2
                if [[ $(expr $end_node - $start_node) -eq 1 ]]; then
                    printf -v end_node "%03d" "$end_node"
                # else control node is 1-10
                else
                    start_node=$(echo "$(expr $start_node + 1)")
                    printf -v start_node "%03d" "$start_node"
                    printf -v end_node "%03d" "$end_node"
                fi
        elif [[ $1 == *[* ]]; then
            hostchar=$(echo "$1" | cut -d'[' -f1)
            start_node=$(echo "$1" | cut -d'[' -f2 | cut -d'-' -f1)
            end_node=$(echo "$1" | cut -d'-' -f2 | cut -d']' -f1)
            if [[ $(expr $end_node - $start_node) -eq 1 ]]; then
                printf -v end_node "%03d" "$end_node"
                echo "$hostchar$end_node $cpus"
            else
                start_node=$(echo "$(expr $start_node + 1)")
                printf -v start_node "%03d" "$start_node"
                printf -v end_node "%03d" "$end_node"
                echo "$hostchar[${start_node}-${end_node}] $cpus"
            fi
        else
            echo "control $cpus"
        fi
    else
        echo "$1 $cpus"
    fi
    
}
################### --END-- ###################
# home_dir="/home/nf/Documents/Dissertation/dissertation-code/bash/unit_tests"
# nlist="c[11-222]"
# cpus="72(x2)"
# cnodes_list=''
# control_machine="c11"
# index=1
# IFS=',' read -r -a nodelist <<< "$nlist"
# for node in ${nodelist[@]}; do
#     echo "check2_nodes result: $(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")"
#     output=$(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")
#     cnodes_txt+="\nNodeName=$( echo ${output} | cut -d ' ' -f 1) ThreadsPerCore=1 RealMemory=57344 State=UNKNOWN"
#     cnodes_txt+="
#     "
#     if [[ "$cnodes_list" != "" ]]; then
#         cnodes_list+=",$( echo ${output} | cut -d ' ' -f 1)"
#     else
#         cnodes_list+="$( echo ${output} | cut -d ' ' -f 1)"
#     fi
#     ((index++))
# done
# echo $cnodes_txt

# config_text=$(head -n -1 $home_dir/slurm.conf.template | tail -n +2 )
# config_text+=$cnodes_txt
# config_text+="\nControlMachine=$control_machine"

# echo -e "$config_text" > $home_dir/slurm.conf
# compute_range=$(echo "$nlist" | cut -d'[' -f2 | cut -d ']' -f1)
# start_node=$(echo "$compute_range" | cut -d'-' -f1)
# host="c"
# hostnum=$(echo "${host}" | tr -cd '[:digit:]')
# echo $hostnum
# echo $start_node
nlist="c[1-2]"
cpus="72"
host="c1"
cnodes_txt=""
echo "Test 1: 72(x2) get c2 72"
echo "$(check2_nodes "$nlist" "$cpus" 1)"
echo "Test 2: Single node"
echo "$(check2_nodes "c1" "72" '0')"
echo "Test 3: Different host"
host="c2"
echo "$(check2_nodes "$nlist" "$cpus" '0')"
echo "Test 4: get c2 72"
echo "$(check2_nodes "$nlist" "$cpus" '1')"
host="c1"
echo "Test 5: slurm.conf"
output=$(check2_nodes "$nlist" "$cpus" '0')
echo "NodeName=$(echo ${output} | cut -d' ' -f 1) RealMemory=1000 CPUs=$(echo ${output} | cut -d' ' -f 2)"
nlist="c[1-10]"
cpus="72(x10)"
echo "Test 6: 72x10 get 72"
output=$(check2_nodes "$nlist" "$cpus" '0')
echo "NodeName=$(echo ${output} | cut -d' ' -f 1) RealMemory=1000 CPUs=$(echo ${output} | cut -d' ' -f 2)"
host="c19"
nlist="c[19-32]"
cpus="72(x14)"
echo "Test 7: 72x14 get 72"
output=$(check2_nodes "$nlist" "$cpus" '0')
echo "NodeName=$(echo ${output} | cut -d' ' -f 1) RealMemory=1000 CPUs=$(echo ${output} | cut -d' ' -f 2)"
nlist="c[19-32],c[1-10]"
cpus="72(x14),32(x10)"
echo "Test 8: 72x14 , 32x10 get full text"
# $( echo $nlist | tr ' ' ',')
index=1
IFS=',' read -r -a nlist <<< "$nlist"
for node in ${nlist[@]}; do
    output=$(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")
    cnodes_txt+="NodeName=$( echo ${output} | cut -d ' ' -f 1) RealMemory=${mem_per_cpu} CPUs=$(echo ${output} | cut -d' ' -f 2)"$'\n'
    ((index++))
done
echo "$cnodes_txt"

echo "Test 9: node002,node[015-19],node[068-255]"
cnodes_list=''
nodelist="node002,node[015-19],node[068-255]"
cpus="72,32(x5),72(x188)"
index=1
count=0
IFS=',' read -r -a nodelist <<< "$nodelist"
for node in ${nodelist[@]}; do
    output=$(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")
    first_arg=$(echo $output | cut -d' ' -f 1)
    echo "first_arg: $first_arg"
    second_arg=$(echo $output | cut -d' ' -f 2)
    if [[ $index -eq 1 ]]; then
        if [[ $first_arg == "control" ]]; then
            ((index++))
            continue
        else
            cnodes_list+="$first_arg,"
        fi
        ((index++))
    else
        cnodes_list+="$first_arg,"
        ((index++))
    fi
done
# Delete trailing comma
cnodes_list=${cnodes_list::-1}
echo "nodes list: $cnodes_list"

echo "Test 10: node[002-007],node[015-019],node[068-255]"
cnodes_list=''
nodelist="node[002-007],node015,node[068-255]"
cpus="72,32(x5),72(x188)"
index=1
count=0
IFS=',' read -r -a nodelist <<< "$nodelist"
for node in ${nodelist[@]}; do
    echo "Node: $node"
    output=$(check2_nodes "$node" "$(echo $cpus | cut -d' ' -f $index)" "${index}")
    first_arg=$(echo $output | cut -d' ' -f 1)
    echo "first_arg: $first_arg"
    second_arg=$(echo $output | cut -d' ' -f 2)
    if [[ $index -eq 1 ]]; then
        if [[ $first_arg == "control" ]]; then
            ((index++))
            continue
        else
            cnodes_list+="$first_arg,"
        fi
        ((index++))
    else
        cnodes_list+="$first_arg,"
        ((index++))
    fi
done
nodelist="node[095,099-100]"

# Delete trailing comma
cnodes_list=${cnodes_list::-1}
echo "nodes list: $cnodes_list"