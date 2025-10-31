#! /bin/bash -l

# Enter your cases here
cases=(
bt.D.64
)

for case in "${cases[@]}";do

	IFS='.' read -r name class procs <<< "$case"

	nodes=$(( ${procs} / 20 ))
	if (( ${nodes} * 20 < ${procs} ));then
		nodes=$(( ${nodes} + 1 ))
	fi

	echo "app=${name}.${class}.${procs},nodes=$nodes,allocation=compact"
	sbatch --nodes=$nodes --partition=compute --export=APP=$name,CLASS=$class,PROCS=$procs run_cmp.NAS.sh

done
