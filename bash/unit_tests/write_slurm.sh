#!/bin/bash
slurm_conf="slurm"
sudo touch "/usr/local/etc/slurm.conf"
sudo chmod 777 /usr/local/etc/slurm.conf
echo "${slurm_conf}" > "/usr/local/etc/slurm.conf"