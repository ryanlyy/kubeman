#!/usr/bin/bash

CFS_CPU_USAGE="/sys/fs/cgroup/cpu/cpuacct.usage"
SAMPLE_INTERVAL=0.5
typeset -i startCnt=0
typeset -i endCnt=0
typeset -i sampleCpu=0

startCnt=0
while [[ 1 ]]; do
    endCnt=$(cat $CFS_CPU_USAGE)
    sampleCpu=$endCnt-$startCnt
    echo $sampleCpu
    startCnt=$endCnt
    sleep 0.5
done