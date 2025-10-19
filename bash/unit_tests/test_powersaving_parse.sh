#!/bin/bash

slurm_conf="#SuspendProgram=
#ResumeProgram=
#SuspendTimeout=
#ResumeTimeout=
#ResumeRate=
#SuspendExcNodes=
#SuspendExcParts=
#SuspendRate=
#SuspendTime="
$(grep -E 'ResumeProgram|SuspendRate' "${slurm_conf}")