CPU, MEM etc resource
---------------

- [CPU Cgroup](#cpu-cgroup)
  - [CPUACCT_USAGE_FILE("/sys/fs/cgroup/cpu/cpuacct.usage");](#cpuacct_usage_filesysfscgroupcpucpuacctusage)
  - [CPUACCT_USAGE_PERCPU_FILE("/sys/fs/cgroup/cpu/cpuacct.usage_percpu");](#cpuacct_usage_percpu_filesysfscgroupcpucpuacctusage_percpu)
  - [CPU_CFS_PERIOD_US_FILE("/sys/fs/cgroup/cpu/cpu.cfs_period_us");](#cpu_cfs_period_us_filesysfscgroupcpucpucfs_period_us)
  - [CPU_CFS_QUOTA_US_FILE("/sys/fs/cgroup/cpu/cpu.cfs_quota_us");](#cpu_cfs_quota_us_filesysfscgroupcpucpucfs_quota_us)
  - [CPU Usage Calculation](#cpu-usage-calculation)
- [MEM Cgroup](#mem-cgroup)
  - [MOMERY_LIMIT_FILE("/sys/fs/cgroup/memory/memory.limit_in_bytes");](#momery_limit_filesysfscgroupmemorymemorylimit_in_bytes)
  - [MOMERY_USAGE_FILE("/sys/fs/cgroup/memory/memory.usage_in_bytes");](#momery_usage_filesysfscgroupmemorymemoryusage_in_bytes)
  - [MEM Usage Calculation](#mem-usage-calculation)

# CPU Cgroup 
The CPU Accounting (cpuacct) subsystem generates automatic reports on CPU resources used by the tasks in a cgroup, including tasks in child groups. 

## CPUACCT_USAGE_FILE("/sys/fs/cgroup/cpu/cpuacct.usage");
reports the total CPU time (in nanoseconds) consumed by all tasks in this cgroup (including tasks lower in the hierarchy).

## CPUACCT_USAGE_PERCPU_FILE("/sys/fs/cgroup/cpu/cpuacct.usage_percpu");
reports the CPU time (in nanoseconds) consumed on each CPU by all tasks in this cgroup (including tasks lower in the hierarchy). 

## CPU_CFS_PERIOD_US_FILE("/sys/fs/cgroup/cpu/cpu.cfs_period_us");
specifies a period of time in microseconds (µs, represented here as "us") for how regularly a cgroup's access to CPU resources should be reallocated. If tasks in a cgroup should be able to access a single CPU for 0.2 seconds out of every 1 second, set cpu.cfs_quota_us to 200000 and cpu.cfs_period_us to 1000000. The upper limit of the cpu.cfs_quota_us parameter is 1 second and the lower limit is 1000 microseconds. 

## CPU_CFS_QUOTA_US_FILE("/sys/fs/cgroup/cpu/cpu.cfs_quota_us");
specifies the total amount of time in microseconds (µs, represented here as "us") for which all tasks in a cgroup can run during one period (as defined by cpu.cfs_period_us). As soon as tasks in a cgroup use up all the time specified by the quota, they are throttled for the remainder of the time specified by the period and not allowed to run until the next period. If tasks in a cgroup should be able to access a single CPU for 0.2 seconds out of every 1 second, set cpu.cfs_quota_us to 200000 and cpu.cfs_period_us to 1000000. Note that the quota and period parameters operate on a CPU basis. To allow a process to fully utilize two CPUs, for example, set cpu.cfs_quota_us to 200000 and cpu.cfs_period_us to 100000.

Setting the value in cpu.cfs_quota_us to -1 indicates that the cgroup does not adhere to any CPU time restrictions. This is also the default value for every cgroup (except the root cgroup). 

## CPU Usage Calculation
const unsigned int DEFAULT_USAGE_COLLECT_INTERVAL = 500; //milliseconds
```
        // The cpu usage percentage fomula is:
        // cpu_usage(%) = ((cpuacct_usage_bfore_PeriodsPerSamplingInterval - cpuacct_usage_after_PeriodsPerSamplingInterval)
        //                /(cpuacct_quota_us * Periods_Per_Sampling_Interval)) * 100
        // The fomula for calculating the 'Periods_Per_Sampling_Interval' is:
        // Periods_Per_Sampling_Interval = sampling_time_us / cpu_cfs_period_us.
        // Here, the value of 'sampling_time_us' should be the same with timer interval.
        cmSend.mCpu = (double)(cmCollect.mCStop - cmCollect.mCStart)
        / (cmCollect.mCpuCfsQuotaUs * cmCollect.mPeriodsPerSamplingInterval);
        cmSend.mCpu = floor(cmSend.mCpu * FACTOR_HUNDRED + FACTOR_HALF) / FACTOR_HUNDRED;
        cmSend.mCpu = cmSend.mCpu * PERCENT;
```

# MEM Cgroup
## MOMERY_LIMIT_FILE("/sys/fs/cgroup/memory/memory.limit_in_bytes");
sets the maximum amount of user memory (including file cache). If no units are specified, the value is interpreted as bytes. However, it is possible to use suffixes to represent larger units — k or K for kilobytes, m or M for megabytes, and g or G for gigabytes. For example, to set the limit to 1 gigabyte, execute:

    ~]# echo 1G > /cgroup/memory/lab1/memory.limit_in_bytes

You cannot use memory.limit_in_bytes to limit the root cgroup; you can only apply values to groups lower in the hierarchy.
Write -1 to memory.limit_in_bytes to remove any existing limits. 

## MOMERY_USAGE_FILE("/sys/fs/cgroup/memory/memory.usage_in_bytes");
reports the total current memory usage by processes in the cgroup (in bytes). 

## MEM Usage Calculation
```

    // The memory usage percentage fomula is:
    // memory_usage(%) = (memory_usage_in_limit / memory_limit_in_bytes) * 100,
    // here, the 'memory_usage_in_limit' means used memory,
    // the 'memory_limit_in_bytes' means memory limited (total requested memory).
    cmSend.mMemory = (double)cmCollect.mUsage / cmCollect.mTotal;
    cmSend.mMemory = floor(cmSend.mMemory * FACTOR_HUNDRED + FACTOR_HALF) / FACTOR_HUNDRED;
    cmSend.mMemory = cmSend.mMemory * PERCENT;

```