#!/bin/bash

# Find all occurrences of slurm.conf
all_slurm_conf=$(find / -name "slurm.conf" 2>/dev/null)

# Check if there's only one
if [[ $(echo "$all_slurm_conf" | wc -l) -eq 1 ]]; then
  slurm_conf="$all_slurm_conf"
  echo "Found single slurm.conf: $slurm_conf"
else
  # Enumerate files with index
  echo "Found multiple slurm.conf files. Please select one:"
  count=1
  for slurm_conf in $all_slurm_conf; do
    echo "$((count++)). $slurm_conf"
  done

  # Prompt user for selection
  read -p "Select slurm.conf (1-$(($count-1))): " choice

  # Validate user input
  if [[ ! "$choice" =~ ^[1-$(($count-1))]$ ]]; then
    echo "Invalid selection. Exiting."
    exit 1
  fi

  # Get selected slurm.conf based on index
  slurm_conf=$(echo "$all_slurm_conf" | sed -n "$choice"p)
fi

# Now you have the selected slurm.conf path in the variable $slurm_conf
# Use it for further processing
declare -A port_dict_file
while IFS= read -r line
do
  key=$(echo "$line" | cut -d '=' -f 1)
  value=$(echo "$line" | cut -d '=' -f 2)
  if [[ $key == "MpiParams" ]]; then
    port_range=$(echo "$value" | cut -d '#' -f 2)
    start_port=$(echo "$port_range" | cut -d '-' -f 1)
    end_port=$(echo "$port_range" | cut -d '-' -f 2)
    index=1
    for ((i=start_port; i<=end_port; i++)); do
      port_dict_file["MpiParams$index"]="$i,1"
      let "index++"
    done
  elif [[ $line == \#* ]]; then
    # 0 flag means the service is not used based on the slurm.conf
    port_dict_file["$key"]="$value,0"
  else
    if [[ $key == "JobCompType" ]]; then
      port_dict_file["$key"]=$(echo "$value" | cut -d '/' -f 2)
    else
      port_dict_file["$key"]="$value,1"
    fi
  fi
done < <(grep -i "SlurmctldPort\|SlurmdPort\|AccountingStoragePort\|JobCompPort\|MpiParams\|JobCompType" $slurm_conf)


sinfo_output=$(sinfo)
partition_dict=()

# Loop through each partition and extract the values
for partition in $(echo "$(sinfo)" | awk 'NR>1 {print $1}'); do
    avail=$(echo "$sinfo_output" | awk -v p="$partition" '$1==p {print $2}')
    timelimit=$(echo "$sinfo_output" | awk -v p="$partition" '$1==p {print $3}')
    nodes=$(echo "$sinfo_output" | awk -v p="$partition" '$1==p {print $4}')
    state=$(echo "$sinfo_output" | awk -v p="$partition" '$1==p {print $5}')
    nodelist=$(echo "$sinfo_output" | awk -v p="$partition" '$1==p {print $6}')
    if [[ $partition == *"*"* ]]; then
        partition=$(echo $partition | tr -d '*')
        partition_dict["$partition"]="chosen $avail $timelimit $nodes $state $nodelist"
    else
        partition_dict["$partition"]="$avail $timelimit $nodes $state $nodelist"
    fi
done

# Run another bash script and capture its output into a variable
declare -A port_dict

port_dict=$(./portscan.sh)
declare -A port_dict=()
while IFS=':' read -r key value; do
    port_dict["$key"]="$value"
done <<< "$port_dict"
# # Print the partition dictionary
# for partition in "${!partition_dict[@]}"; do
#     echo "Partition: $partition"
#     echo "Values: ${partition_dict[$partition]}"
# done
