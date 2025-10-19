#!/bin/bash
selfcgroup=$(cat /proc/self/cgroup)
echo $selfcgroup