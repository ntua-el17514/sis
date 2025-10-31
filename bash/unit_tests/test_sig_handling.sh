function handle_scancel_sig() {

}

function handle_walltime_sig() {
    kill $(ps -s $$ -o sid=)
}

function handle_srun_sig() {

}

trap handle_walltime_sig SIGINT
