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

# Print port dictionary from slurm.conf
for key in "${!port_dict_file[@]}"; do
  echo "$key: ${port_dict_file[$key]}"
done
