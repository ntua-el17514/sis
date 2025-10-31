#!/bin/bash
. ../helpers.sh
# parse_nlist() {
#     # If arguments of function different from 2 exit
#     if [[ $# -ne 1 ]]; then
#         echo "Function parse_nlist requires 1 arguments <nodelist>"
#         exit 1
#     fi
#     # Extract how many chars on a range entry
#     num_chars=$(echo "$1" | cut -d'[' -f 2 | cut -d']' -f 1 | cut -d'-' -f 2 | cut -d ',' -f 1 | wc -c) 
#     num_chars=$(expr $num_chars - 1)
#     echo "$num_chars"
#     hostchar=$(echo "$1" | cut -d'[' -f1)
#     range=$(echo "$1" | cut -d'[' -f2 | cut -d']' -f1)
#     IFS=, read -r -a parts <<< "$range"
#     for i in "${!parts[@]}"; do
#         if [[ ${parts[$i]} == *-* ]]; then
#             start_node="$(echo ${parts[$i]} | cut -d'-' -f1)"
#             end_node="$(echo ${parts[$i]} | cut -d'-' -f2)"
#             if [[ $num_chars -eq 3 ]]; then
#                 printf -v start_node "%03i" $(( 10#$start_node ))
#                 printf -v end_node "%03i" $(( 10#$end_node ))
#             else
#                 printf -v start_node "%02i" $(( 10#$start_node ))
#                 printf -v end_node "%02i" $(( 10#$end_node ))
#             fi
#             parts[$i]="${start_node}-${end_node}"
#         else
#             node=${parts[$i]}
#             if [[ $num_chars -eq 3 ]]; then
#                 printf -v node "%03i" $(( 10#$node ))
#             else
#                 printf -v node "%02i" $(( 10#$node ))
#             fi
#             parts[$i]=$node
#         fi
#     done
#     part1=${parts[0]}
#     if [[ $part1 == *-* ]]; then
#         start_node=$(echo $part1 | cut -d'-' -f1)
#         end_node=$(echo $part1 | cut -d'-' -f2)
#         if [[ $(expr $end_node - $start_node) -eq 1 ]]; then
#             parts[0]=$end_node
#         else
#             start_node=$(echo "$(expr $start_node + 1)")
#             if [[ $num_chars -eq 3 ]]; then
#                 printf -v start_node "%03i" $(( 10#$start_node ))
#             else
#                 printf -v start_node "%02i" $(( 10#$start_node ))
#             fi
#             parts[0]="${start_node}-${end_node}"
#         fi
#     else
#         parts=( "${parts[@]/$part1}" )
#     fi
#     echo "$hostchar[$(echo ${parts[@]} | sed 's/ /,/g')]"
# }

nodelist="node[95,99-100,105]"
parse_nlist $nodelist

nodelist="node[95-97,99-100,105]"
parse_nlist $nodelist

nodelist="node[1,5,7]"
parse_nlist $nodelist

nodelist="node[1-3,5-8,12-19]"
parse_nlist $nodelist

nodelist="node1"
parse_nlist $nodelist

nodelist="node[099-100,419]"
parse_nlist $nodelist

nodelist="phi[02-04,08]"
parse_nlist $nodelist

nodelist="node[080-082]"
parse_nlist $nodelist
