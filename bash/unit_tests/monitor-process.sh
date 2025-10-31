#!/bin/bash

# Check for required arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <pid> <output_file>"
    exit 1
fi

# Get the process ID and output file
pid=$1
output_file=$2

# Trap all signals and log them to the output file
trap 'echo "$(date +%H:%M:%S) - Received signal SIG$?" >> '"$output_file"'' SIGINT SIGTERM SIGQUIT SIGHUP SIGUSR1 SIGUSR2 EXIT

# Validate process ID
if ! kill -0 $pid &> /dev/null; then
    echo "Error: Process with PID $pid does not exist."
    exit 1
fi

# Print initial message
echo "Monitoring process $pid for signals. Log file: $output_file"

# Wait for process termination
while ps -p $pid > /dev/null 2>&1; do
    sleep 0.1  # Adjust sleep time as needed
done

# Print final message
echo "Process $pid terminated. Signal information logged to $output_file."
