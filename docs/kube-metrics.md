Metrics
-------

- [Kubelet metrics](#kubelet-metrics)


# Kubelet metrics
```golang
const (
	KubeletSubsystem                   = "kubelet"
	NodeNameKey                        = "node_name"
	NodeLabelKey                       = "node"
	NodeStartupPreKubeletKey           = "node_startup_pre_kubelet_duration_seconds"
	NodeStartupPreRegistrationKey      = "node_startup_pre_registration_duration_seconds"
	NodeStartupRegistrationKey         = "node_startup_registration_duration_seconds"
	NodeStartupPostRegistrationKey     = "node_startup_post_registration_duration_seconds"
	NodeStartupKey                     = "node_startup_duration_seconds"
	PodWorkerDurationKey               = "pod_worker_duration_seconds"
	PodStartDurationKey                = "pod_start_duration_seconds"
	PodStartSLIDurationKey             = "pod_start_sli_duration_seconds"
	PodStartTotalDurationKey           = "pod_start_total_duration_seconds"
	CgroupManagerOperationsKey         = "cgroup_manager_duration_seconds"
	PodWorkerStartDurationKey          = "pod_worker_start_duration_seconds"
	PodStatusSyncDurationKey           = "pod_status_sync_duration_seconds"
	PLEGRelistDurationKey              = "pleg_relist_duration_seconds"
	PLEGDiscardEventsKey               = "pleg_discard_events"
	PLEGRelistIntervalKey              = "pleg_relist_interval_seconds"
	PLEGLastSeenKey                    = "pleg_last_seen_seconds"
	EventedPLEGConnErrKey              = "evented_pleg_connection_error_count"
	EventedPLEGConnKey                 = "evented_pleg_connection_success_count"
	EventedPLEGConnLatencyKey          = "evented_pleg_connection_latency_seconds"
	EvictionsKey                       = "evictions"
	EvictionStatsAgeKey                = "eviction_stats_age_seconds"
	PreemptionsKey                     = "preemptions"
	VolumeStatsCapacityBytesKey        = "volume_stats_capacity_bytes"
	VolumeStatsAvailableBytesKey       = "volume_stats_available_bytes"
	VolumeStatsUsedBytesKey            = "volume_stats_used_bytes"
	VolumeStatsInodesKey               = "volume_stats_inodes"
	VolumeStatsInodesFreeKey           = "volume_stats_inodes_free"
	VolumeStatsInodesUsedKey           = "volume_stats_inodes_used"
	VolumeStatsHealthStatusAbnormalKey = "volume_stats_health_status_abnormal"
	RunningPodsKey                     = "running_pods"
	RunningContainersKey               = "running_containers"
	DesiredPodCountKey                 = "desired_pods"
	ActivePodCountKey                  = "active_pods"
	MirrorPodCountKey                  = "mirror_pods"
	WorkingPodCountKey                 = "working_pods"
	OrphanedRuntimePodTotalKey         = "orphaned_runtime_pods_total"
	RestartedPodTotalKey               = "restarted_pods_total"

	// Metrics keys of remote runtime operations
	RuntimeOperationsKey         = "runtime_operations_total"
	RuntimeOperationsDurationKey = "runtime_operations_duration_seconds"
	RuntimeOperationsErrorsKey   = "runtime_operations_errors_total"
	// Metrics keys of device plugin operations
	DevicePluginRegistrationCountKey  = "device_plugin_registration_total"
	DevicePluginAllocationDurationKey = "device_plugin_alloc_duration_seconds"
	// Metrics keys of pod resources operations
	PodResourcesEndpointRequestsTotalKey          = "pod_resources_endpoint_requests_total"
	PodResourcesEndpointRequestsListKey           = "pod_resources_endpoint_requests_list"
	PodResourcesEndpointRequestsGetAllocatableKey = "pod_resources_endpoint_requests_get_allocatable"
	PodResourcesEndpointErrorsListKey             = "pod_resources_endpoint_errors_list"
	PodResourcesEndpointErrorsGetAllocatableKey   = "pod_resources_endpoint_errors_get_allocatable"
	PodResourcesEndpointRequestsGetKey            = "pod_resources_endpoint_requests_get"
	PodResourcesEndpointErrorsGetKey              = "pod_resources_endpoint_errors_get"

	// Metrics keys for RuntimeClass
	RunPodSandboxDurationKey = "run_podsandbox_duration_seconds"
	RunPodSandboxErrorsKey   = "run_podsandbox_errors_total"

	// Metrics to keep track of total number of Pods and Containers started
	StartedPodsTotalKey             = "started_pods_total"
	StartedPodsErrorsTotalKey       = "started_pods_errors_total"
	StartedContainersTotalKey       = "started_containers_total"
	StartedContainersErrorsTotalKey = "started_containers_errors_total"

	// Metrics to track HostProcess container usage by this kubelet
	StartedHostProcessContainersTotalKey       = "started_host_process_containers_total"
	StartedHostProcessContainersErrorsTotalKey = "started_host_process_containers_errors_total"

	// Metrics to track ephemeral container usage by this kubelet
	ManagedEphemeralContainersKey = "managed_ephemeral_containers"

	// Metrics to track the CPU manager behavior
	CPUManagerPinningRequestsTotalKey = "cpu_manager_pinning_requests_total"
	CPUManagerPinningErrorsTotalKey   = "cpu_manager_pinning_errors_total"

	// Metrics to track the Topology manager behavior
	TopologyManagerAdmissionRequestsTotalKey = "topology_manager_admission_requests_total"
	TopologyManagerAdmissionErrorsTotalKey   = "topology_manager_admission_errors_total"
	TopologyManagerAdmissionDurationKey      = "topology_manager_admission_duration_ms"

	// Metrics to track orphan pod cleanup
	orphanPodCleanedVolumesKey       = "orphan_pod_cleaned_volumes"
	orphanPodCleanedVolumesErrorsKey = "orphan_pod_cleaned_volumes_errors"

	// Metric for tracking garbage collected images
	ImageGarbageCollectedTotalKey = "image_garbage_collected_total"

	// Values used in metric labels
	Container          = "container"
	InitContainer      = "init_container"
	EphemeralContainer = "ephemeral_container"
)
```