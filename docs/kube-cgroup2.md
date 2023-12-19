This page is used to explore cgroup2 cadvisor implementation
------

- [Kubelet Metrics API](#kubelet-metrics-api)
- [Memory Usage (kubectl top)](#memory-usage-kubectl-top)
- [CPU Usage (kubectl top)](#cpu-usage-kubectl-top)
- [GetStates() - which is periodly query cpu/mem etc. states every 100ms or housekeeping\_interval/2](#getstates---which-is-periodly-query-cpumem-etc-states-every-100ms-or-housekeeping_interval2)
- [Cgroup Subsystem](#cgroup-subsystem)
- [metrics-server - REST API](#metrics-server---rest-api)
  - [Pod API - pkg/api/pod.go](#pod-api---pkgapipodgo)
  - [Node API - /pkg/api/node.go](#node-api---pkgapinodego)
- [metrics-server - getMetrics from kubelet](#metrics-server---getmetrics-from-kubelet)
- [Tick scriper metrics from kubelet](#tick-scriper-metrics-from-kubelet)
  - [Store Pod Metrics](#store-pod-metrics)
  - [Store Node Metrics](#store-node-metrics)


# Kubelet Metrics API
```golang
var (
        nodeCPUUsageDesc = metrics.NewDesc("node_cpu_usage_seconds_total",
                "Cumulative cpu time consumed by the node in core-seconds",
                nil,
                nil,
                metrics.STABLE,
                "")

        nodeMemoryUsageDesc = metrics.NewDesc("node_memory_working_set_bytes",
                "Current working set of the node in bytes",
                nil,
                nil,
                metrics.STABLE,
                "")

        nodeSwapUsageDesc = metrics.NewDesc("node_swap_usage_bytes",
                "Current swap usage of the node in bytes. Reported only on non-windows systems",
                nil,
                nil,
                metrics.ALPHA,
                "")

        containerCPUUsageDesc = metrics.NewDesc("container_cpu_usage_seconds_total",
                "Cumulative cpu time consumed by the container in core-seconds",
                []string{"container", "pod", "namespace"},
                nil,
                metrics.STABLE,
                "")
        containerMemoryUsageDesc = metrics.NewDesc("container_memory_working_set_bytes",
                "Current working set of the container in bytes",
                []string{"container", "pod", "namespace"},
                nil,
                metrics.STABLE,
                "")
        ...

        podCPUUsageDesc = metrics.NewDesc("pod_cpu_usage_seconds_total",
                "Cumulative cpu time consumed by the pod in core-seconds",
                []string{"pod", "namespace"},
                nil,
                metrics.STABLE,
                "")

        podMemoryUsageDesc = metrics.NewDesc("pod_memory_working_set_bytes",
                "Current working set of the pod in bytes",
                []string{"pod", "namespace"},
                nil,
                metrics.STABLE,
                "")
        ...

// DescribeWithStability implements metrics.StableCollector
func (rc *resourceMetricsCollector) DescribeWithStability(ch chan<- *metrics.Desc) {
        ch <- nodeCPUUsageDesc
        ch <- nodeMemoryUsageDesc
        ch <- nodeSwapUsageDesc
        ch <- containerStartTimeDesc
        ch <- containerCPUUsageDesc
        ch <- containerMemoryUsageDesc
        ch <- containerSwapUsageDesc
        ch <- podCPUUsageDesc
        ch <- podMemoryUsageDesc
        ch <- podSwapUsageDesc
        ch <- resourceScrapeResultDesc
        ch <- resourceScrapeErrorResultDesc
}

// Check if resourceMetricsCollector implements necessary interface
var _ metrics.StableCollector = &resourceMetricsCollector{}

/home/ryanl/pkgsrc/kubernets/kubernetes-1.25.0/vendor/github.com/opencontainers/runc/libcontainer/cgroups/fs2/memory.go

        machineInfo := &info.MachineInfo{
                Timestamp:        time.Now(),
                CPUVendorID:      GetCPUVendorID(cpuinfo),
                NumCores:         numCores,
                NumPhysicalCores: GetPhysicalCores(cpuinfo),
                NumSockets:       GetSockets(cpuinfo),
                CpuFrequency:     clockSpeed,
                MemoryCapacity:   memoryCapacity, //regexp.MustCompile(`MemTotal:\s*([0-9]+) kB`)
                MemoryByType:     memoryByType,
                SwapCapacity:     swapCapacity,
                NVMInfo:          nvmInfo,
                HugePages:        hugePagesInfo,
                DiskMap:          diskMap,
                NetworkDevices:   netDevices,
                Topology:         topology,
                MachineID:        getInfoFromFiles(filepath.Join(rootFs, *machineIDFilePath)),
                SystemUUID:       systemUUID,
                BootID:           getInfoFromFiles(filepath.Join(rootFs, *bootIDFilePath)),
                CloudProvider:    cloudProvider,
                InstanceType:     instanceType,
                InstanceID:       instanceID,
        }

// Provider hosts methods required by stats handlers.
type Provider interface {
        // The following stats are provided by either CRI or cAdvisor.
        //
        // ListPodStats returns the stats of all the containers managed by pods.
        ListPodStats(ctx context.Context) ([]statsapi.PodStats, error)
        // ListPodStatsAndUpdateCPUNanoCoreUsage updates the cpu nano core usage for
        // the containers and returns the stats for all the pod-managed containers.
        ListPodCPUAndMemoryStats(ctx context.Context) ([]statsapi.PodStats, error)
        ...

// CreateHandlers creates the REST handlers for the stats.
func CreateHandlers(rootPath string, provider Provider, summaryProvider SummaryProvider) *restful.WebService {
        h := &handler{provider, summaryProvider}

        ws := &restful.WebService{}
        ws.Path(rootPath).
                Produces(restful.MIME_JSON)

        endpoints := []struct {
                path    string
                handler restful.RouteFunction
        }{
                {"/summary", h.handleSummary},

// Handles stats summary requests to /stats/summary
// If "only_cpu_and_memory" GET param is true then only cpu and memory is returned in response.
func (h *handler) handleSummary(request *restful.Request, response *restful.Response) {
// CollectWithStability implements metrics.StableCollector
// Since new containers are frequently created and removed, using the Gauge would
// leak metric collectors for containers or pods that no longer exist.  Instead, implement
// custom collector in a way that only collects metrics for active containers.
func (rc *resourceMetricsCollector) CollectWithStability(ch chan<- metrics.Metric) {

        statsSummary, err := rc.provider.GetCPUAndMemoryStats(ctx)
        podStats, err := sp.provider.ListPodCPUAndMemoryStats(ctx)
                        infos, err := getCadvisorContainerInfo(p.cadvisor)
                                infos, err := ca.ContainerInfoV2("/", cadvisorapiv2.RequestOptions{
                                        IdType:    cadvisorapiv2.TypeName,
                                        Count:     2, // 2 samples are needed to compute "instantaneous" CPU
                                        Recursive: true,
                                })
                                        cc.GetContainerInfoV2(name, options) //client
                                                //server
                                                containers, err := m.getRequestedContainers(containerName, options)
                                                result := v2.ContainerInfo{}
                                                cinfo, err := container.GetInfo(false)
                                                        err := cd.updateSpec()
                                                                spec, err := cd.handler.GetSpec()
                                                                        getSpecInternal(cgroupPaths, machineInfoFactory, hasNetwork, hasFilesystem, cgroups.IsCgroup2UnifiedMode())
                                                                                var spec info.ContainerSpec //zero its contents
                                                                                mi, err := machineInfoFactory.GetMachineInfo()
                                                                                //CPU
                                                                                cpuRoot, ok := GetControllerPath(cgroupPaths, "cpu", cgroup2UnifiedMode)
                                                                                //cgroup2
                                                                                weight := readUInt64(cpuRoot, "cpu.weight")
                                                                                limit, err := convertCPUWeightToCPULimit(weight)
                                                                                spec.Cpu.Limit = limit
                                                                                max := readString(cpuRoot, "cpu.max")
                                                                                if max != "" {
                                                                                        splits := strings.SplitN(max, " ", 2)   
                                                                                        if splits[0] != "max" {
                                                                                                spec.Cpu.Quota = parseUint64String(splits[0])
                                                                                        }
                                                                                        spec.Cpu.Period = parseUint64String(splits[1])
                                                                                }
                                                                                //cgroup
                                                                                spec.Cpu.Limit = readUInt64(cpuRoot, "cpu.shares")
                                                                                spec.Cpu.Period = readUInt64(cpuRoot, "cpu.cfs_period_us")
                                                                                quota := readString(cpuRoot, "cpu.cfs_quota_us")
                                                                                val, err := strconv.ParseUint(quota, 10, 64)
                                                                                spec.Cpu.Quota = val
                                                                                //MEMORY
                                                                                memoryRoot, ok := GetControllerPath(cgroupPaths, "memory", cgroup2UnifiedMode)
                                                                                //cgroup2
                                                                                spec.Memory.Reservation = readUInt64(memoryRoot, "memory.min")
                                                                                spec.Memory.Limit = readUInt64(memoryRoot, "memory.max")
                                                                                        out := readString(dirpath, file)
                                                                                        if out == "max" {
                                                                                                return math.MaxUint64
                                                                                        }
                                                                                spec.Memory.SwapLimit = readUInt64(memoryRoot, "memory.swap.max")
                                                                                //cgroup
                                                                                spec.Memory.Limit = readUInt64(memoryRoot, "memory.limit_in_bytes")
                                                                                spec.Memory.SwapLimit = readUInt64(memoryRoot, "memory.memsw.limit_in_bytes")
                                                                                spec.Memory.Reservation = readUInt64(memoryRoot, "memory.soft_limit_in_bytes")
                                                                cd.info.Spec = spec
                                                                cInfo := containerInfo{
                                                                        Subcontainers: cd.info.Subcontainers,
                                                                        Spec:          cd.info.Spec,
                                                                }
                                                                cInfo.Id = cd.info.Id
                                                                cInfo.Name = cd.info.Name
                                                                cInfo.Aliases = cd.info.Aliases
                                                                cInfo.Namespace = cd.info.Namespace
                                                                return &cInfo, nil
                                                result.Spec = m.getV2Spec(cinfo)
                                                        spec := m.getAdjustedSpec(cinfo)
                                                        if spec.Memory.Limit == 0 { spec.Memory.Limit = uint64(m.machineInfo.MemoryCapacity) }
                                                        return v2.ContainerSpecFromV1(&spec, cinfo.Aliases, cinfo.Namespace)
                                                                        specV2 := ContainerSpec{
                                                                                CreationTime:     specV1.CreationTime,
                                                                                HasCpu:           specV1.HasCpu,
                                                                                HasMemory:        specV1.HasMemory,
                                                                                HasHugetlb:       specV1.HasHugetlb,
                                                                                HasFilesystem:    specV1.HasFilesystem,
                                                                                HasNetwork:       specV1.HasNetwork,
                                                                                HasProcesses:     specV1.HasProcesses,
                                                                                HasDiskIo:        specV1.HasDiskIo,
                                                                                HasCustomMetrics: specV1.HasCustomMetrics,
                                                                                Image:            specV1.Image,
                                                                                Labels:           specV1.Labels,
                                                                                Envs:             specV1.Envs,
                                                                        }
                                                                        if specV1.HasCpu {
                                                                                specV2.Cpu.Limit = specV1.Cpu.Limit
                                                                                specV2.Cpu.MaxLimit = specV1.Cpu.MaxLimit
                                                                                specV2.Cpu.Mask = specV1.Cpu.Mask
                                                                        }
                                                                        if specV1.HasMemory {
                                                                                specV2.Memory.Limit = specV1.Memory.Limit
                                                                                specV2.Memory.Reservation = specV1.Memory.Reservation
                                                                                specV2.Memory.SwapLimit = specV1.Memory.SwapLimit
                                                                        }
                                                                        if specV1.HasCustomMetrics {
                                                                                specV2.CustomMetrics = specV1.CustomMetrics
                                                                        }
                                                                        specV2.Aliases = aliases
                                                                        specV2.Namespace = namespace
                                                                        return specV2
                                                // popujate cpu/memory usage which is queryed by timer housekeepingTick
                                                stats, err := m.memoryCache.RecentStats(name, nilTime, nilTime, options.Count)
                                                        cstore, ok = c.containerCacheMap[name]; 
                                                        return cstore.RecentStats(start, end, maxStats)
                                                result.Stats = v2.ContainerStatsFromV1(containerName, &cinfo.Spec, stats)
                                                        stat.Cpu = &val.Cpu
                                                        stat.Memory = &val.Memory
                cpu, memory := cadvisorInfoToCPUandMemoryStats(podInfo)
                        //cpu
                        cpuStats.UsageCoreNanoSeconds = &cstat.Cpu.Usage.Total
                        //memory
                        pageFaults := cstat.Memory.ContainerData.Pgfault
                        majorPageFaults := cstat.Memory.ContainerData.Pgmajfault
                        memoryStats = &statsapi.MemoryStats{
                                Time:            metav1.NewTime(cstat.Timestamp),
                                UsageBytes:      &cstat.Memory.Usage,
                                WorkingSetBytes: &cstat.Memory.WorkingSet,
                                RSSBytes:        &cstat.Memory.RSS,
                                PageFaults:      &pageFaults,
                                MajorPageFaults: &majorPageFaults,
                        }
                        if !isMemoryUnlimited(info.Spec.Memory.Limit) {
                                availableBytes := info.Spec.Memory.Limit - cstat.Memory.WorkingSet
                                memoryStats.AvailableBytes = &availableBytes
                        }
        rc.collectNodeCPUMetrics(ch, statsSummary.Node)
        rc.collectNodeMemoryMetrics(ch, statsSummary.Node)
        rc.collectNodeSwapMetrics(ch, statsSummary.Node)

        for _, pod := range statsSummary.Pods {
                for _, container := range pod.Containers {
                        rc.collectContainerStartTime(ch, pod, container)
                        rc.collectContainerCPUMetrics(ch, pod, container)
                        rc.collectContainerMemoryMetrics(ch, pod, container)
                        rc.collectContainerSwapMetrics(ch, pod, container)
                }
                rc.collectPodCPUMetrics(ch, pod)
                rc.collectPodMemoryMetrics(ch, pod)
                rc.collectPodSwapMetrics(ch, pod)
        }
}

func (rc *resourceMetricsCollector) collectContainerCPUMetrics(ch chan<- metrics.Metric, pod summary.PodStats, s summary.ContainerStats) {
        if s.CPU == nil || s.CPU.UsageCoreNanoSeconds == nil {
                return
        }

        ch <- metrics.NewLazyMetricWithTimestamp(s.CPU.Time.Time,
                metrics.NewLazyConstMetric(containerCPUUsageDesc, metrics.CounterValue,
                        float64(*s.CPU.UsageCoreNanoSeconds)/float64(time.Second), s.Name, pod.PodRef.Name, pod.PodRef.Namespace))
}

func (rc *resourceMetricsCollector) collectContainerMemoryMetrics(ch chan<- metrics.Metric, pod summary.PodStats, s summary.ContainerStats) {
        if s.Memory == nil || s.Memory.WorkingSetBytes == nil {
                return
        }

        ch <- metrics.NewLazyMetricWithTimestamp(s.Memory.Time.Time,
                metrics.NewLazyConstMetric(containerMemoryUsageDesc, metrics.GaugeValue,
                        float64(*s.Memory.WorkingSetBytes), s.Name, pod.PodRef.Name, pod.PodRef.Namespace))
}


```
# Memory Usage (kubectl top)
```golang
func setMemoryStats(s *cgroups.Stats, ret *info.ContainerStats) {
        ret.Memory.Usage = s.MemoryStats.Usage.Usage
        ret.Memory.MaxUsage = s.MemoryStats.Usage.MaxUsage
        ret.Memory.Failcnt = s.MemoryStats.Usage.Failcnt

        if cgroups.IsCgroup2UnifiedMode() {
                ret.Memory.Cache = s.MemoryStats.Stats["file"]
                ret.Memory.RSS = s.MemoryStats.Stats["anon"]
                ret.Memory.Swap = s.MemoryStats.SwapUsage.Usage - s.MemoryStats.Usage.Usage
                ret.Memory.MappedFile = s.MemoryStats.Stats["file_mapped"]
        } else if s.MemoryStats.UseHierarchy {
                ret.Memory.Cache = s.MemoryStats.Stats["total_cache"]
                ret.Memory.RSS = s.MemoryStats.Stats["total_rss"]
                ret.Memory.Swap = s.MemoryStats.Stats["total_swap"]
                ret.Memory.MappedFile = s.MemoryStats.Stats["total_mapped_file"]
        } else {
                ret.Memory.Cache = s.MemoryStats.Stats["cache"]
                ret.Memory.RSS = s.MemoryStats.Stats["rss"]
                ret.Memory.Swap = s.MemoryStats.Stats["swap"]
                ret.Memory.MappedFile = s.MemoryStats.Stats["mapped_file"]
        }
        if v, ok := s.MemoryStats.Stats["pgfault"]; ok {
                ret.Memory.ContainerData.Pgfault = v
                ret.Memory.HierarchicalData.Pgfault = v
        }
        if v, ok := s.MemoryStats.Stats["pgmajfault"]; ok {
                ret.Memory.ContainerData.Pgmajfault = v
                ret.Memory.HierarchicalData.Pgmajfault = v
        }
        inactiveFileKeyName := "total_inactive_file"
        if cgroups.IsCgroup2UnifiedMode() {
                inactiveFileKeyName = "inactive_file"
        }

        workingSet := ret.Memory.Usage
        if v, ok := s.MemoryStats.Stats[inactiveFileKeyName]; ok {
                if workingSet < v {
                        workingSet = 0
                } else {
                        workingSet -= v
                }
        }
        ret.Memory.WorkingSet = workingSet
}

func statMemory(dirPath string, stats *cgroups.Stats) error {
        const file = "memory.stat"
        statsFile, err := cgroups.OpenFile(dirPath, file, os.O_RDONLY)
        if err != nil {
                return err
        }
        defer statsFile.Close()

        sc := bufio.NewScanner(statsFile)
        for sc.Scan() {
                t, v, err := fscommon.ParseKeyValue(sc.Text())
                if err != nil {
                        return &parseError{Path: dirPath, File: file, Err: err}
                }
                stats.MemoryStats.Stats[t] = v
        }
        if err := sc.Err(); err != nil {
                return &parseError{Path: dirPath, File: file, Err: err}
        }
        stats.MemoryStats.Cache = stats.MemoryStats.Stats["file"]
        // Unlike cgroup v1 which has memory.use_hierarchy binary knob,
        // cgroup v2 is always hierarchical.
        stats.MemoryStats.UseHierarchy = true
        stats.MemoryStats.Cache = stats.MemoryStats.Stats["file"]
        // Unlike cgroup v1 which has memory.use_hierarchy binary knob,
        // cgroup v2 is always hierarchical.
        stats.MemoryStats.UseHierarchy = true

        memoryUsage, err := getMemoryDataV2(dirPath, "")
        if err != nil {
                if errors.Is(err, unix.ENOENT) && dirPath == UnifiedMountpoint {
                        // The root cgroup does not have memory.{current,max}
                        // so emulate those using data from /proc/meminfo.
                        return statsFromMeminfo(stats)
                }
                return err
        }
        stats.MemoryStats.Usage = memoryUsage
        swapUsage, err := getMemoryDataV2(dirPath, "swap")
        if err != nil {
                return err
        }
        // As cgroup v1 reports SwapUsage values as mem+swap combined,
        // while in cgroup v2 swap values do not include memory,
        // report combined mem+swap for v1 compatibility.
        swapUsage.Usage += memoryUsage.Usage
        if swapUsage.Limit != math.MaxUint64 {
                swapUsage.Limit += memoryUsage.Limit
        }
        stats.MemoryStats.SwapUsage = swapUsage

        return nil
}
func getMemoryDataV2(path, name string) (cgroups.MemoryData, error) {
        memoryData := cgroups.MemoryData{}

        moduleName := "memory"
        if name != "" {
                moduleName = "memory." + name
        }
        usage := moduleName + ".current"
        limit := moduleName + ".max"

        value, err := fscommon.GetCgroupParamUint(path, usage)
        if err != nil {
                if name != "" && os.IsNotExist(err) {
                        // Ignore EEXIST as there's no swap accounting
                        // if kernel CONFIG_MEMCG_SWAP is not set or
                        // swapaccount=0 kernel boot parameter is given.
                        return cgroups.MemoryData{}, nil
                }
                return cgroups.MemoryData{}, err
        }
        memoryData.Usage = value

        value, err = fscommon.GetCgroupParamUint(path, limit)
        if err != nil {
                return cgroups.MemoryData{}, err
        }
        memoryData.Limit = value

        return memoryData, nil
}
```
# CPU Usage (kubectl top)
```golang
func statCpu(dirPath string, stats *cgroups.Stats) error {
        case "usage_usec":
               stats.CpuStats.CpuUsage.TotalUsage = v * 1000
        case "user_usec":
               stats.CpuStats.CpuUsage.UsageInUsermode = v * 1000
        case "system_usec":
               stats.CpuStats.CpuUsage.UsageInKernelmode = v * 1000
        case "nr_periods":
               stats.CpuStats.ThrottlingData.Periods = v
        case "nr_throttled":
               stats.CpuStats.ThrottlingData.ThrottledPeriods = v
        case "throttled_usec":
                stats.CpuStats.ThrottlingData.ThrottledTime = v * 1000

func setCPUStats(s *cgroups.Stats, ret *info.ContainerStats, withPerCPU bool) 
        ret.Cpu.Usage.User = s.CpuStats.CpuUsage.UsageInUsermode
        ret.Cpu.Usage.System = s.CpuStats.CpuUsage.UsageInKernelmode
        ret.Cpu.Usage.Total = s.CpuStats.CpuUsage.TotalUsage
        ret.Cpu.CFS.Periods = s.CpuStats.ThrottlingData.Periods
        ret.Cpu.CFS.ThrottledPeriods = s.CpuStats.ThrottlingData.ThrottledPeriods
        ret.Cpu.CFS.ThrottledTime = s.CpuStats.ThrottlingData.ThrottledTime
        ret.Cpu.Usage.PerCpu = s.CpuStats.CpuUsage.PercpuUsage //cgroup

// Returns instantaneous number of running tasks in a group.
// Caller can use historical data to calculate cpu load.
// path is an absolute filesystem path for a container under the CPU cgroup hierarchy.
// NOTE: non-hierarchical load is returned. It does not include load for subcontainers.
func (r *NetlinkReader) GetCpuLoad(name string, path string) (info.LoadStats, error) {
        cfd, err := os.Open(path)
        stats, err := getLoadStats(r.familyID, cfd, r.conn)
                // Get load stats for a task group.
                // id: family id for taskstats.
                // cfd: open file to path to the cgroup directory under cpu hierarchy.
                // conn: open netlink connection used to communicate with kernel.
                func getLoadStats(id uint16, cfd *os.File, conn *Connection) (info.LoadStats, error) 
                        unix.CGROUPSTATS_CMD_ATTR_FD
                        unix.CGROUPSTATS_CMD_GET
                        // Extract task stats from response returned by kernel.
                        func parseLoadStatsResp(msg syscall.NetlinkMessage) (*loadStatsResp, error) {

        return stats, ni
}
```

# GetStates() - which is periodly query cpu/mem etc. states every 100ms or housekeeping_interval/2
```golang
var HousekeepingInterval = flag.Duration("housekeeping_interval", 1*time.Second, "Interval between container housekeepings")

func (cd *containerData) Start() error {
        go cd.housekeeping()
        func (cd *containerData) housekeeping() 
                // Long housekeeping is either 100ms or half of the housekeeping interval.
                longHousekeeping := 100 * time.Millisecond
                if *HousekeepingInterval/2 < longHousekeeping {
                        longHousekeeping = *HousekeepingInterval / 2
                }
                cd.housekeepingTick(houseKeepingTimer.C(), longHousekeeping)
                func (cd *containerData) housekeepingTick(timer <-chan time.Time, longHousekeeping time.Duration) bool 
                        err := cd.updateStats()
                        func (cd *containerData) updateStats() error {
                                stats, statsErr := cd.handler.GetStats()
                                // Get cgroup and networking stats of the specified container
                                func (h *Handler) GetStats() (*info.ContainerStats, error) {
                                        cgroupStats, err := h.cgroupManager.GetStats()
                                        // vendor/github.com/opencontainers/runc/libcontainer/cgroups/fs2/fs2.go
                                        // get state of PID, Memory, CPU, IO, hugetlb, rdma
                                        func (m *manager) GetStats() (*cgroups.Stats, error)
                                                cgroups.Stats *st := cgroups.NewStats()
                                                statPids(m.dirPath, st)
                                                statMemory(m.dirPath, st)
                                                statIo(m.dirPath, st)
                                                statCpu(m.dirPath, st)
                                                statHugeTlb(m.dirPath, st)
                                                fscommon.RdmaGetStats(m.dirPath, st)
                                        libcontainerStats := &libcontainer.Stats{
                                                CgroupStats: cgroupStats,
                                        }
                                        stats := newContainerStats(libcontainerStats, h.includedMetrics)
                                        func newContainerStats(libcontainerStats *libcontainer.Stats, includedMetrics container.MetricSet) *info.ContainerStats {
                                                ret := &info.ContainerStats{
                                                        Timestamp: time.Now(),
                                                }
                                                s := libcontainerStats.CgroupStats;
                                                setCPUStats(s, ret, includedMetrics.Has(container.PerCpuUsageMetrics))
                                                setDiskIoStats(s, ret)
                                                setMemoryNumaStats(s, ret)
                                                setHugepageStats(s, ret)
                                                setCPUSetStats(s, ret)
                                                setNetworkStats(libcontainerStats, ret)
                                        stats.Cpu.Schedstat, err = h.schedulerStatsFromProcs()
                                        pids, err := h.cgroupManager.GetPids()
                                        stats.ReferencedMemory, err = referencedBytesStat(pids, h.cycles, *referencedResetInterval)
                                        netStats, err := networkStatsFromProc(h.rootFs, h.pid)
                                        stats.Network.Interfaces = append(stats.Network.Interfaces, netStats...)
                                        t, err := tcpStatsFromProc(h.rootFs, h.pid, "net/tcp")
                                        stats.Network.Tcp = t
                                        t6, err := tcpStatsFromProc(h.rootFs, h.pid, "net/tcp6")
                                        stats.Network.Tcp6 = t6
                                        ta, err := advancedTCPStatsFromProc(h.rootFs, h.pid, "net/netstat", "net/snmp")
                                        stats.Network.TcpAdvanced = ta
                                        u, err := udpStatsFromProc(h.rootFs, h.pid, "net/udp")
                                        stats.Network.Udp = u
                                        u6, err := udpStatsFromProc(h.rootFs, h.pid, "net/udp6")
                                        stats.Network.Udp6 = u6
                                        path, ok := common.GetControllerPath(h.cgroupManager.GetPaths(), "cpu", cgroups.IsCgroup2UnifiedMode())
                                        setThreadsStats(cgroupStats, stats)
                                        stats.Network.InterfaceStats = stats.Network.Interfaces[0] //backward compatibility
                                        return stats
                                path, err := cd.handler.GetCgroupPath("cpu")
                                func (h *containerdContainerHandler) GetCgroupPath(resource string) (string, error) {
                                        //cgroup: res = resource
                                        //cgroup2: res = "" 
                                        //please refer to Cgroup Subsystem Section
                                        path, ok := h.cgroupPaths[res]

                                loadStats, err := cd.loadReader.GetCpuLoad(cd.info.Name, path)
                                stats.TaskStats = loadStats
                                cd.updateLoad(loadStats.NrRunning)
                                // convert to 'milliLoad' to avoid floats and preserve precision.
                                stats.Cpu.LoadAverage = int32(cd.loadAvg * 1000)
                                err := cd.summaryReader.AddSample(*stats)
                                stats.OOMEvents = atomic.LoadUint64(&cd.oomEvents)
                                cm := cd.collectorManager.(*collector.GenericCollectorManager)
                                customStats, err := cd.updateCustomStats()
                                stats.CustomMetrics = customStats
                                perfStatsErr := cd.perfCollector.UpdateStats(stats)
                                resctrlStatsErr := cd.resctrlCollector.UpdateStats(stats)
                                ref, err := cd.handler.ContainerReference()
                                cInfo := info.ContainerInfo{
                                        ContainerReference: ref,
                                }
                                err = cd.memoryCache.AddStats(&cInfo, stats)
                                func (c *InMemoryCache) AddStats(cInfo *info.ContainerInfo, stats *info.ContainerStats) error {
                                        var cstore *containerCache
                                        cstore, ok = c.containerCacheMap[cInfo.ContainerReference.Name]
                                        if !ok  {
                                                cstore = newContainerStore(cInfo.ContainerReference, c.maxAge)
                                                c.containerCacheMap[cInfo.ContainerReference.Name] = cstore
                                        }
                                        return cstore.AddStats(stats)
                                                c.recentStats.Add(stats.Timestamp, stats)
```

# Cgroup Subsystem
```golang
// GetCgroupSubsystems returns information about the cgroup subsystems that are
// of interest as a map of cgroup controllers to their mount points.
// For example, "cpu" -> "/sys/fs/cgroup/cpu".
//
// The incudeMetrics arguments specifies which metrics are requested,
// and is used to filter out some cgroups and their mounts. If nil,
// all supported cgroup subsystems are included.
//
// For cgroup v2, includedMetrics argument is unused, the only map key is ""
// (empty string), and the value is the unified cgroup mount point.
func GetCgroupSubsystems(includedMetrics container.MetricSet) (map[string]string, error) {
        if cgroups.IsCgroup2UnifiedMode() {
                return map[string]string{"": fs2.UnifiedMountpoint}, nil
        }
        // Get all cgroup mounts.
        allCgroups, err := cgroups.GetCgroupMounts(true)
        if err != nil {
                return nil, err
        }

        return getCgroupSubsystemsHelper(allCgroups, includedMetrics)
}

const UnifiedMountpoint = "/sys/fs/cgroup"
```

# metrics-server - REST API
## Pod API - pkg/api/pod.go
```golang
var _ rest.KindProvider = &podMetrics{}
var _ rest.Storage = &podMetrics{}
var _ rest.Getter = &podMetrics{}
var _ rest.Lister = &podMetrics{}
var _ rest.TableConvertor = &podMetrics{}
var _ rest.Scoper = &podMetrics{}
```

## Node API - /pkg/api/node.go
```golang
var _ rest.KindProvider = &nodeMetrics{}
var _ rest.Storage = &nodeMetrics{}
var _ rest.Getter = &nodeMetrics{}
var _ rest.Lister = &nodeMetrics{}
var _ rest.Scoper = &nodeMetrics{}
var _ rest.TableConvertor = &nodeMetrics{}
```

# metrics-server - getMetrics from kubelet
```golang
var (
        nodeCpuUsageMetricName       = []byte("node_cpu_usage_seconds_total")
        nodeMemUsageMetricName       = []byte("node_memory_working_set_bytes")
        containerCpuUsageMetricName  = []byte("container_cpu_usage_seconds_total")
        containerMemUsageMetricName  = []byte("container_memory_working_set_bytes")
        containerStartTimeMetricName = []byte("container_start_time_seconds")
)


// GetMetrics implements client.KubeletMetricsGetter
func (kc *kubeletClient) GetMetrics(ctx context.Context, node *corev1.Node) (*storage.MetricsBatch, error) {
        url := url.URL{
                Scheme: kc.scheme,
                Host:   net.JoinHostPort(addr, strconv.Itoa(port)),
                Path:   "/metrics/resource",
        }
        return kc.getMetrics(ctx, url.String(), node.Name)
                ms, err := decodeBatch(b, requestTime, nodeName)
                        res := &storage.MetricsBatch{
                                Nodes: make(map[string]storage.MetricsPoint),
                                Pods:  make(map[apitypes.NamespacedName]storage.PodMetricsPoint),
                        }
                        node := &storage.MetricsPoint{}
                        pods := make(map[apitypes.NamespacedName]storage.PodMetricsPoint)
                        parser := textparse.New(b, "")
                        for {
                                err = parser.Next(); err != nil {
                                if err == io.EOF {
                                        break
                                }
                                timeseries, maybeTimestamp, value := parser.Series()
                                switch {
                                case timeseriesMatchesName(timeseries, nodeCpuUsageMetricName):
                                        parseNodeCpuUsageMetrics(*maybeTimestamp, value, node)
                                case timeseriesMatchesName(timeseries, nodeMemUsageMetricName):
                                        parseNodeMemUsageMetrics(*maybeTimestamp, value, node)
                                case timeseriesMatchesName(timeseries, containerCpuUsageMetricName):
                                        namespaceName, containerName := parseContainerLabels(timeseries[len(containerCpuUsageMetricName):])
                                        parseContainerCpuMetrics(namespaceName, containerName, *maybeTimestamp, value, pods)
                                                // unit of node_cpu_usage_seconds_total is second, need to convert to nanosecond
                                                containerMetrics := pods[namespaceName].Containers[containerName]
                                                containerMetrics.CumulativeCpuUsed = uint64(value * 1e9)
                                                // unit of timestamp is millisecond, need to convert to nanosecond
                                                containerMetrics.Timestamp = time.Unix(0, timestamp*1e6)
                                                pods[namespaceName].Containers[containerName] = containerMetrics

                                case timeseriesMatchesName(timeseries, containerMemUsageMetricName):
                                        namespaceName, containerName := parseContainerLabels(timeseries[len(containerMemUsageMetricName):])
                                        parseContainerMemMetrics(namespaceName, containerName, *maybeTimestamp, value, pods)
                                                containerMetrics := pods[namespaceName].Containers[containerName]
                                                containerMetrics.MemoryUsage = uint64(value)
                                                // unit of timestamp is millisecond, need to convert to nanosecond
                                                containerMetrics.Timestamp = time.Unix(0, timestamp*1e6)
                                                pods[namespaceName].Containers[containerName] = containerMetrics

                                case timeseriesMatchesName(timeseries, containerStartTimeMetricName):
                                        namespaceName, containerName := parseContainerLabels(timeseries[len(containerStartTimeMetricName):])
                                        parseContainerStartTimeMetrics(namespaceName, containerName, *maybeTimestamp, value, pods)
                                default:
                                        continue
                                }
                        }
                        res.Nodes[nodeName] = *node
                        for podRef, podMetric := range pods {
                                pm := storage.PodMetricsPoint {
                                        Containers: checkContainerMetrics(podMetric),
                                }
                                res.Pods[podRef] = pm
                        } 
}
```

# Tick scriper metrics from kubelet

```golang
MetricResolution: 60 * time.Second

msfs.DurationVar(&o.MetricResolution, "metric-resolution", o.MetricResolution, "The resolution at which metrics-server will retain metrics, must set value at least 10s.")

func main() 
        func NewMetricsServerCommand(stopCh <-chan struct{}) *cobra.Command 
                func runCommand(o *options.Options, stopCh <-chan struct{}) error
                        func (s *server) RunUntil(stopCh <-chan struct{})
                                // Start informers
                                go s.nodes.Run(stopCh)
                                go s.pods.Run(stopCh)
                                // Start serving API and scrape loop
                                go s.runScrape(ctx)
                                func (s *server) runScrape(ctx context.Context)
                                        ticker := time.NewTicker(s.resolution)
                                        func (s *server) tick(ctx context.Context, startTime time.Time)
                                                klog.V(6).InfoS("Scraping metrics")
                                                data := s.scraper.Scrape(ctx)
                                                        nodes, err := c.nodeLister.List(labels.Everything())
                                                        klog.V(1).InfoS("Scraping metrics from nodes", "nodeCount", len(nodes))
                                                        for _, node := range nodes {
                                                                go {
                                                                        klog.V(2).InfoS("Scraping node", "node", klog.KObj(node))
                                                                        m, err := c.collectNode(ctx, node)
                                                                                ms, err := c.kubeletClient.GetMetrics(ctx, node)
                                                                                return ms
                                                                        responseChannel <- m
                                                                }
                                                        }
                                                        for range nodes {
                                                                srcBatch := <-responseChannel
                                                                for nodeName, nodeMetricsPoint := range srcBatch.Nodes {
                                                                        res.Nodes[nodeName] = nodeMetricsPoint
                                                                }
                                                                for podRef, podMetricsPoint := range srcBatch.Pods {
                                                                        res.Pods[podRef] = podMetricsPoint
                                                                }
                                                        }
                                                        return res
                                                klog.V(6).InfoS("Storing metrics")
                                                s.storage.Store(data)
                                                        s.nodes.Store(batch)
                                                        s.pods.Store(batch)

```
## Store Pod Metrics
```golang
func (s *podStorage) Store(newPods *MetricsBatch) {
        for podRef, newPod := range newPods.Pods {
                for containerName, newPoint := range newPod.Containers {
                        newLastPod.Containers[containerName] = newPoint
                        newPrevPod.Containers[containerName] = prevPod.Containers[containerName]
                }
                prevPods[podRef] = newPrevPod
                lastPods[podRef] = newLastPod        
        }
        s.last = lastPods
        s.prev = prevPods
}
```
## Store Node Metrics
```golang
func (s *nodeStorage) Store(batch *MetricsBatch) {
        for nodeName, newPoint := range batch.Nodes {
                lastNodes[nodeName] = newPoint
                 prevNodes[nodeName] = prevPoint
        }
        s.last = lastNodes
        s.prev = prevNodes
}
```
