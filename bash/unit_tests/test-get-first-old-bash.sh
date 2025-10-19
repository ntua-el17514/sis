#!/bin/bash

get_first_node_old_bash () {
    hostchar=$(echo "$1" | cut -d'[' -f1)
    range=$(echo "$1" | cut -d'[' -f2 | cut -d']' -f1)
    IFS=, read -r -a parts <<< "$range"
    if [[ $parts[0] == *-* ]]; then
        node=$(echo $parts[0] | cut -d '-' -f1 )
        echo "$hostchar$node"
    elif [[ $parts == $hostchar ]]; then
        echo "$hostchar"
    else 
        echo "$hostchar$parts"
    fi
}

input="node[155-157]"
start_number=$(get_first_node_old_bash $input)
echo "Start number: $start_number"

input="node[155,156-157,157]"
start_number=$(get_first_node_old_bash $input)
echo "Start number: $start_number"

input="node155"
start_number=$(get_first_node_old_bash $input)
echo "Start number: $start_number"

input="node[155-157,159-160,162-169]"
start_number=$(get_first_node_old_bash $input)
echo "Start number: $start_number"