#!/bin/bash -l

#!/bin/bash -l
. ./environment_variables.sh
. ./helpers.sh

mkdir --parents $home_dir $base_dir
cd $home_dir
major="${version%%.*}"
generate_slurm_conf $major
if (( major <= 16 )); then
	module purge
    module load gnu/8
    module load intel/18
    module load intelmpi/2018
	if [[ $1 == "--install" || $1 == "-i" ]]; then

	    mkdir --parents ${home_dir%/}{/sbin,/lib/slurm,/etc,/spool/{slurm,slurmd},/sys,/sys/{fs,fs/cgroup},/var/{run,log,log/slurm,slurm,spool/{slurm,slurmd}},/spool/slurmd}
	    touch ${home_dir%/}/var/run/slurmctld.pid ${home_dir%/}/var/spool/slurm/{node_state,job_state,trigger_state}
	    chmod 755 -R ${home_dir%/}
	    # Create certificates
	    openssl req -x509 -newkey rsa:4096 -passout pass:$password -keyout $key_name -out $cert_name -sha256 -days 365
	    # Store them in $home_dir/etc/
	    cp $cert_name $key_name ${home_dir%/}/etc/

	    # Copy slurm.conf.template and cgroup.conf to $home_dir/etc/
	    cp {${base_dir%/}/slurm.conf.template,${base_dir%/}/cgroup.conf} ${home_dir%/}/etc
	    cd ${home_dir%/}/etc/
	    openssl genpkey -algorithm RSA -out $key_name -pkeyopt rsa_keygen_bits:2048
	    openssl rsa -pubout -in $key_name -out $pkey_name
	    cd ${home_dir%/}
	    wget https://github.com/SchedMD/slurm/archive/refs/tags/slurm-16-05-11-1.zip
	    unzip *slurm*.zip
	    cp *slurm*.zip ${base_dir%/}
	    rm -f *slurm*.zip
	    cd ${home_dir%/}/slurm*/
	    ./configure --prefix=${home_dir%/} --exec-prefix=${home_dir%/} --sysconfdir=${home_dir%/}/etc --localstatedir=${home_dir%/}/var --with-ssl=/usr/lib64/openssl #/engines/lib
	    # if the script is in unfinished state then you have to manually create and copy the slurm.conf file
	    cd ${home_dir%/}/slurm*/src/
	    make -j8

	elif [[ $1 == "--configure" || $1 == "-c" ]]; then
	    # Remove old installation
	    rm -rf ${home_dir%/}/*
	    # Copy source from home_dir to installation directory
	    cp ${base_dir%/}/slurm*.zip $home_dir
	    # Unzip the source code
	    unzip *slurm*.zip
	    # Create directories
	    mkdir --parents ${home_dir%/}/{lib/slurm,etc,spool/{slurm,slurmd},sys,sys/{fs,fs/cgroup},var/{run,log,log/slurm,slurm,spool/slurm},spool/slurmd}
	    touch ${home_dir%/}/var/run/slurmctld.pid ${home_dir%/}/var/spool/slurm/{node_state,job_state,trigger_state} ${home_dir%/}/var/slurm/slurmd.pid
	    # Store keys in $home_dir/etc/
	    cp ${base_dir%/}/{$cert_name,$key_name} ${home_dir%/}/etc/

	    # Copy slurm.conf.template and cgroup.conf to $home_dir/etc/
	    cp ${base_dir%/}/slurm.conf.template.$version ${base_dir%/}/cgroup.conf ${home_dir%/}/etc/slurm.conf.template

	    cd ${home_dir%/}/etc/
	    openssl genpkey -algorithm RSA -out $key_name -pkeyopt rsa_keygen_bits:2048
	    openssl rsa -pubout -in $key_name -out $pkey_name
	    # openssl rsa -passin pass:$password -in $key_name -out $key_name # Remove passphrase

	    cd ${home_dir%/}/slurm*/
	    ./configure --prefix=$home_dir --exec-prefix=$home_dir --sysconfdir=${home_dir%/}/etc --localstatedir=${home_dir%/}/var --with-ssl=/usr/lib64/openssl #/engines/lib
	    cd ${home_dir%/}/slurm*/src/
	    make -j8

	else
	    echo "Invalid argument. Choose either '--install -i' or '--configure -c'"
	fi

	if [[ $1 == "--install" || $1 == "-i" || $1 == "--configure" || $1 == "-c" ]]; then
	    # Plugin linking
	    lib_dir="${home_dir%/}/lib/slurm"
	    so_files=$(find ${home_dir%/}/slurm-*/src/plugins/ -type f -name "*.so")
	    cd ${lib_dir%/}

	    IFS=$'\n'
	    # Create symlinks for object code
	    for so_file in $so_files; do
	        ln -s $so_file $(basename $so_file)
	    done
	    ln -s ${home_dir%/}/slurm-*/src/slurmd/slurmstepd/slurmstepd ${home_dir%/}/sbin/slurmstepd
	fi
elif (( major == 25 )); then
	if [[ $1 == "--install" || $1 == "-i" ]]; then
		cd ${home_dir%/}
        wget https://github.com/SchedMD/slurm/archive/refs/tags/slurm-25-05-1-1.zip
        unzip *slurm*.zip
        cp *slurm*.zip ${base_dir%/}
        rm -f *slurm*.zip
        mkdir --parents ${home_dir%/}{/sbin,/lib/slurm,/etc,/spool/{slurm,slurmd},/sys,/sys/{fs,fs/cgroup},/var/{run,log,log/slurm,slurm,spool/{slurm,slurmd}},/spool/slurmd}
		cp ${base_dir%/}/slurm.conf.template.$version ${home_dir%/}/etc/slurm.conf.template
		cp ${base_dir%/}/cgroup.conf ${home_dir%/}/etc/cgroup.conf
		cd ${home_dir%/}/slurm*/
        ./configure --prefix=${home_dir%/} --exec-prefix=$home_dir --sysconfdir=${home_dir%/}/etc --localstatedir=${home_dir%/}/var
        cd ${home_dir%/}/slurm*/src/
        make -j8
		find ${home_dir%/}/slurm-slurm-25-05-1-1/ -type f -name "*.so" -exec cp {} ${home_dir%/}/lib/slurm/ \;
        find ${home_dir%/}/slurm*/etc/ -type f -name "*lua*" - exec cp {} ${home_dir%/}/etc/
        cp ${home_dir%/}/etc/job_submit.lua.example ${home_dir%/}/etc/job_submit.lua
	elif [[ $1 == "--configure" || $1 == "-c" ]]; then
		rm -rf ${home_dir%/}/*
		cp ${base_dir%/}/slurm*.zip $home_dir
		Unzip the source code
		unzip *slurm*.zip
		Create directories
		mkdir --parents ${home_dir%/}/{lib/slurm,etc,spool/{slurm,slurmd},sys,sys/{fs,fs/cgroup},var/{run,log,log/slurm,slurm,spool/slurm},spool/slurmd}
		cp ${base_dir%/}/slurm.conf.template.$version ${home_dir%/}/etc/slurm.conf.template
        cp ${base_dir%/}/cgroup.conf ${home_dir%/}/etc/cgroup.conf
		cd ${home_dir%/}/slurm*/
        ./configure --prefix=${home_dir%/} --exec-prefix=$home_dir --sysconfdir=${home_dir%/}/etc --localstatedir=${home_dir%/}/var
        cd ${home_dir%/}/slurm*/src/
        make -j8
		find ${home_dir%/}/slurm-slurm-25-05-1-1/ -type f -name "*.so" -exec cp {} ${home_dir%/}/lib/slurm/ \;
		find ${home_dir%/}/slurm*/etc/ -type f -name "*lua*" - exec cp {} ${home_dir%/}/etc/
		cp ${home_dir%/}/etc/job_submit.lua.example ${home_dir%/}/etc/job_submit.lua
    else
	    echo "Invalid argument. Choose either '--install -i' or '--configure -c'"
	fi
elif (( major == 21 )); then
    if [[ $1 == "--install" || $1 == "-i" ]]; then
        rm -rf ${home_dir%/}/*
		cd ${home_dir%/}
        wget https://github.com/SchedMD/slurm/archive/refs/tags/slurm-21-08-6-1.zip
        unzip *slurm*.zip
        cp *slurm*.zip ${base_dir%/}
        rm -f *slurm*.zip
        mkdir --parents ${home_dir%/}{/sbin,/lib/slurm,/etc,/spool/{slurm,slurmd},/sys,/sys/{fs,fs/cgroup},/var/{run,log,log/slurm,slurm,spool/{slurm,slurmd}},/spool/slurmd}
        cp {${base_dir%/}/slurm.conf.template,${base_dir%/}/cgroup.conf} ${home_dir%/}/etc
        cd ${home_dir%/}/slurm*/
        ./configure --prefix=${home_dir%/} --exec-prefix=$home_dir --sysconfdir=${home_dir%/}/etc --localstatedir=${home_dir%/}/var
        cd ${home_dir%/}/slurm*/src/
        make -j8
    elif [[ $1 == "--configure" || $1 == "-c" ]]; then
        rm -rf ${home_dir%/}/*
        # Copy source from home_dir to installation directory
        cp ${base_dir%/}/slurm*.zip $home_dir
        Unzip the source code
        unzip *slurm*.zip
        Create directories
        mkdir --parents ${home_dir%/}/{lib/slurm,etc,spool/{slurm,slurmd},sys,sys/{fs,fs/cgroup},var/{run,log,log/slurm,slurm,spool/slurm},spool/slurmd}
        cp {${base_dir%/}/slurm.conf.template,${base_dir%/}/cgroup.conf} ${home_dir%/}/etc
        cd ${home_dir%/}/slurm*/
        ./configure --prefix=${home_dir%/} --exec-prefix=$home_dir --sysconfdir=${home_dir%/}/etc --localstatedir=${home_dir%/}/var
        cd ${home_dir%/}/slurm*/src/
        make -j8
        find ${home_dir%/}/slurm-slurm-25-05-1-1/ -type f -name "*.so" -exec cp {} ${home_dir%/}/lib/slurm/ \;
    else
	    echo "Invalid argument. Choose either '--install -i' or '--configure -c'"
	fi
    
fi
