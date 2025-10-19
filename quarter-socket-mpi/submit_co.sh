#! /bin/bash -l
source find_max_min.sh
# Quarter node cores
qnc=5

cases=(mg.D.64_ft.D.64_bt.D.64_sp.D.64)
DEBUG=false
POLICY="maxnodes"

if $DEBUG; then
	echo "Debugging mode"
	mode="dbg"
	time="00:20:00"
	mkdir -p $PWD/logs_dbg
else
	mode="prod"
	time="00:10:00"
	mkdir -p $PWD/logs
fi

for case in "${cases[@]}";do

	IFS='_' read -r app app2 app3 app4<<< "$case"
	IFS='.' read -r name class proc <<< "$app"
	IFS='.' read -r name2 class2 proc2 <<< "$app2"
	IFS='.' read -r name3 class3 proc3 <<< "$app3"
	IFS='.' read -r name4 class4 proc4 <<< "$app4"

	apps=$(sort_apps $app $app2 $app3 $app4)
	readarray -t apps_array <<< "$apps"

	# Get how many nodes will be needed
	max_app=${apps_array[${#apps_array[@]}-1]}
	max_proc=$(awk -F. '{print $3}' <<< "$max_app")
	count_processes=$(( max_proc * 4 ))
	nodes_count=$(( ($count_processes + 19)/20 ))
	apps_with_copies=()
	# Calculate how many copies of each program will be needed
	for app in "${apps_array[@]}"; do
		proc=$(awk -F. '{print $3}' <<< "$app")
		copies=$(( ( max_proc + proc - 1 ) / proc ))
		apps_with_copies+=("${app}.${copies}")
	done
	apps_joined=$(IFS=_; echo "${apps_with_copies[*]}")
	printf '%s\n' "${apps_with_copies[@]}"
	echo "max_proc=$max_proc count_processes=$count_processes nodes_count=$nodes_count"
	sbatch --nodes=$nodes_count --partition=compute --time=$time --export=POLICY=$POLICY,CASE=$case,APPS_ARRAY="$apps_joined",CORES=$qnc,NODES_COUNT=$nodes_count,DEBUG=$DEBUG,TIME=$time run_cos.NAS_NAS.sh
done
