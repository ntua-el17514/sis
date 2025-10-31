#!/bin/bash

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

get_first_node_old_bash () {
    input_string=$1
    if [[ $1 == *[* ]]; then
        char=$(echo $input_string | cut -d '[' -f 1)
        node=$(echo $input_string | cut -d '[' -f 2 | cut -d '-' -f 1)
        echo "$char$node"
    else
        echo $1
    fi
}
# Example usage
input="example-name[123-456]"
start_number=$(get_first_node_old_bash "$input")
echo "Start number: $start_number"
input="c[1-4]"
start_number=$(get_first_node_old_bash "$input")
echo "Start number: $start_number"
input="c1"
start_number=$(get_first_node_old_bash "$input")
echo "Start number: $start_number"
input="node[155-157]"
start_number=$(get_first_node_old_bash "$input")
echo "Start number: $start_number"