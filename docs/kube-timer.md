this page is list all timer that kubernetes used
----

- [Kubernetes Timer Summary](#kubernetes-timer-summary)
- [kube-apiservers timer](#kube-apiservers-timer)
  - [| apiserver | shutdown-watch-termination-grace-period | This option, if set, represents the maximum amount of grace period the apiserver will wait for active watch request(s) to drain during the graceful server shutdown window. |||](#-apiserver--shutdown-watch-termination-grace-period--this-option-if-set-represents-the-maximum-amount-of-grace-period-the-apiserver-will-wait-for-active-watch-requests-to-drain-during-the-graceful-server-shutdown-window-)
- [kube-controller-manager timer](#kube-controller-manager-timer)
  - [|| route-reconciliation-period  | The period for reconciling routes created for Nodes by cloud provider. | 10s ||](#-route-reconciliation-period---the-period-for-reconciling-routes-created-for-nodes-by-cloud-provider--10s-)
- [kube-scheduler timer](#kube-scheduler-timer)
  - [|| log-flush-frequency | Maximum number of seconds between log flushes | 5s ||](#-log-flush-frequency--maximum-number-of-seconds-between-log-flushes--5s-)
- [kube-proxy timer](#kube-proxy-timer)
  - [|| ipvs-udp-timeout | 	The timeout for IPVS UDP packets, 0 to leave as-is. (e.g. '5s', '1m', '2h22m'). |||](#-ipvs-udp-timeout--the-timeout-for-ipvs-udp-packets-0-to-leave-as-is-eg-5s-1m-2h22m-)


# Kubernetes Timer Summary

| Category | Timer Name | Timer Description | Timer Default Values | Configuration Location | 
|----------|----------|----------|----------|----------|
| kubelet | syncFrequency | the max period between synchronizing running containers and config | 1m ||
| kubelet | fileCheckFrequency | the duration between checking config files for new data | 20s | |
| kubelet | httpCheckFrequency | the duration between checking http for new data | 20s | |
| kubelet | streamingConnectionIdleTimeout | the maximum time a streaming connection can be idle before the connection is automatically closed | 4h ||
| kubelet | nodeStatusUpdateFrequency | the frequency that kubelet computes node status. If node lease feature is not enabled, it is also the frequency that kubelet posts node status to master. Note: When node lease feature is not enabled, be cautious when changing the constant, it must work with nodeMonitorGracePeriod in nodecontroller | 10s ||
| kubelet | nodeStatusReportFrequency | nodeStatusReportFrequency is the frequency that kubelet posts node status to master if node status does not change. Kubelet will ignore this frequency and post node status immediately if any change is detected. It is only used when node lease feature is enabled. nodeStatusReportFrequency's default value is 5m. But if nodeStatusUpdateFrequency is set explicitly, nodeStatusReportFrequency's default value will be set to nodeStatusUpdateFrequency for backward compatibility. | 5m ||
| kubelet | imageMinimumGCAge |  the minimum age for an unused image before it is garbage collected. | 2m ||
| kubelet | volumeStatsAggPeriod | the frequency for calculating and caching volume disk usage for all pods | 1m ||
| kubelet | cpuManagerReconcilePeriod | the reconciliation period for the CPU Manager. Requires the CPUManager feature gate to be enabled. | 10s ||
| kubelet | runtimeRequestTimeout | the timeout for all runtime requests except long running requests - pull, logs, exec and attach. | 2m ||
| kubelet | cpuCFSQuotaPeriod | the CPU CFS quota period value, cpu.cfs_period_us. The value must be between 1 ms and 1 second, inclusive. Requires the CustomCPUCFSQuotaPeriod feature gate to be enabled | 100ms ||
| kubelet | evictionPressureTransitionPeriod  | the duration for which the kubelet has to wait before transitioning out of an eviction pressure condition | 5m ||
| kubelet | evictionMaxPodGracePeriod | the maximum allowed grace period (in seconds) to use when terminating pods in response to a soft eviction threshold being met. This value effectively caps the Pod's terminationGracePeriodSeconds value during soft evictions. Note: Due to issue #64530, the behavior has a bug where this value currently just overrides the grace period during soft eviction, which can increase the grace period from what is set on the Pod | 0s ||
| kubelet | shutdownGracePeriod  | the total duration that the node should delay the shutdown and total grace period for pod termination during a node shutdown | 0s ||
| kubelet | shutdownGracePeriodCriticalPods | the duration used to terminate critical pods during a node shutdown. This should be less than shutdownGracePeriod. For example, if shutdownGracePeriod=30s, and shutdownGracePeriodCriticalPods=10s, during a node shutdown the first 20 seconds would be reserved for gracefully terminating normal pods, and the last 10 seconds would be reserved for terminating critical pods | 0s ||
| kubelet | nodeLeaseDurationSeconds | he duration the Kubelet will set on its corresponding Lease. NodeLease provides an indicator of node health by having the Kubelet create and periodically renew a lease, named after the node, in the kube-node-lease namespace. If the lease expires, the node can be considered unhealthy. The lease is currently renewed every 10s, per KEP-0009. In the future, the lease renewal interval may be set based on the lease duration. The field value must be greater than 0 | 40s ||

---

# kube-apiservers timer

| Category | Timer Name | Timer Description | Timer Default Values | Configuration Location | 
|----------|----------|----------|----------|----------|
| apiserver | audit-log-batch-max-wait | The amount of time to wait before force writing the batch that hadn't reached the max size. Only used in batch mode. | No default ||
| apiserver | audit-log-maxage | The maximum number of days to retain old audit log files based on the timestamp encoded in their filename | No default ||
| apiserver | audit-webhook-batch-max-wait | The amount of time to wait before force writing the batch that hadn't reached the max size. Only used in batch mode | 30s ||
| apiserver | audit-webhook-initial-backoff | The amount of time to wait before retrying the first failed request | 10s ||
| apisever | authentication-token-webhook-cache-ttl  | The duration to cache responses from the webhook token authenticator. | 2m0s ||
| apiserver | authorization-webhook-cache-authorized-ttl  |  The duration to cache 'authorized' responses from the webhook authorizer. | 5m0s ||
| apiserver | authorization-webhook-cache-unauthorized-ttl | The duration to cache 'unauthorized' responses from the webhook authorizer. | 30s ||
| apiserver | default-not-ready-toleration-seconds | 	Indicates the tolerationSeconds of the toleration for notReady:NoExecute that is added by default to every pod that does not already have such a toleration. | 300s ||
| apiserver | default-unreachable-toleration-seconds | Indicates the tolerationSeconds of the toleration for unreachable:NoExecute that is added by default to every pod that does not already have such a toleration. | 300s ||
| apiserver | etcd-compaction-interval | The interval of compaction requests. If 0, the compaction request from apiserver is disabled. | 5m0s ||
| apiserver | etcd-count-metric-poll-period | Frequency of polling etcd for number of resources per type. 0 disables the metric collection || 1m0s ||
| apiserver | etcd-db-metric-poll-interval | 	The interval of requests to poll etcd and update metric. 0 disables the metric collection | 30s ||
| apiserver | etcd-healthcheck-timeout | 	The timeout to use when checking etcd health. | 2s ||
| apiserver | etcd-readycheck-timeout  | 	The timeout to use when checking etcd readiness | 2s ||
| apiserver | event-ttl | Amount of time to retain events. | 1h0m0s ||
| apiserver | kubelet-timeout  | Timeout for kubelet operations. | 5s ||
| apiserver | lease-reuse-duration-seconds | The time in seconds that each lease is reused. A lower value could avoid large number of objects reusing the same lease. Notice that a too small value may cause performance problems at storage layer | 60s ||
| apiserver | livez-grace-period | This option represents the maximum amount of time it should take for apiserver to complete its startup sequence and become live. From apiserver's start time to when this amount of time has elapsed, /livez will assume that unfinished post-start hooks will complete successfully and therefore return true. |||
| apiserver | log-flush-frequency | Maximum number of seconds between log flushes | 5s ||
| apiserver | min-request-timeout | An optional field indicating the minimum number of seconds a handler must keep a request open before timing it out. Currently only honored by the watch request handler, which picks a randomized value above this number as the connection timeout, to spread out load. | 1800s ||
| apiserver | request-timeout  | An optional field indicating the duration a handler must keep a request open before timing it out. This is the default request timeout for requests but may be overridden by flags such as --min-request-timeout for specific types of requests. | 1m0s ||
| apiserver | service-account-max-token-expiration | The maximum validity duration of a token created by the service account token issuer. If an otherwise valid TokenRequest with a validity duration larger than this value is requested, a token will be issued with a validity duration of this value. |||
| apiserver | shutdown-delay-duration | Time to delay the termination. During that time the server keeps serving requests normally. The endpoints /healthz and /livez will return success, but /readyz immediately returns failure. Graceful termination starts after this delay has elapsed. This can be used to allow load balancer to stop sending traffic to this server. |||
| apiserver | shutdown-watch-termination-grace-period | This option, if set, represents the maximum amount of grace period the apiserver will wait for active watch request(s) to drain during the graceful server shutdown window. |||
---

# kube-controller-manager timer

| Category | Timer Name | Timer Description | Timer Default Values | Configuration Location | 
|----------|----------|----------|----------|----------|
| | attach-detach-reconcile-sync-period | The reconciler sync wait time between volume attach detach. This duration must be larger than one second, and increasing this value from the default may allow for volumes to be mismatched with pods. | 1m0s ||
| | authentication-token-webhook-cache-ttl | The duration to cache responses from the webhook token authenticator. | 10 s||
| | authorization-webhook-cache-authorized-ttl  | 	The duration to cache 'authorized' responses from the webhook authorizer. | 10s ||
| | authorization-webhook-cache-unauthorized-ttl  | 	The duration to cache 'unauthorized' responses from the webhook authorizer. | 10s ||
| | cluster-signing-duration |  The max length of duration signed certificates will be given. Individual CSRs may request shorter certs by setting spec.expirationSeconds. | 8760h0m0s ||
| | endpoint-updates-batch-period | The length of endpoint updates batching period. Processing of pod changes will be delayed by this duration to join them with potential upcoming updates and reduce the overall number of endpoints updates. Larger number = higher endpoint programming latency, but lower number of endpoints revision generated |||
| | endpointslice-updates-batch-period  | The length of endpoint slice updates batching period. Processing of pod changes will be delayed by this duration to join them with potential upcoming updates and reduce the overall number of endpoints updates. Larger number = higher endpoint programming latency, but lower number of endpoints revision generated |||
| | horizontal-pod-autoscaler-cpu-initialization-period | The period after pod start when CPU samples might be skipped. | 5m0s ||
| | horizontal-pod-autoscaler-downscale-stabilization  | The period for which autoscaler will look backwards and not scale down below any recommendation it made during that period. | 5m0s ||
| | horizontal-pod-autoscaler-initial-readiness-delay | The period after pod start during which readiness changes will be treated as initial readiness. | 30s ||
| | horizontal-pod-autoscaler-sync-period  | The period for syncing the number of pods in horizontal pod autoscaler. | 15s ||
| | leader-elect-lease-duration | The duration that non-leader candidates will wait after observing a leadership renewal until attempting to acquire leadership of a led but unrenewed leader slot. This is effectively the maximum duration that a leader can be stopped before it is replaced by another candidate. This is only applicable if leader election is enabled. | 15s ||
| | leader-elect-renew-deadline | The interval between attempts by the acting master to renew a leadership slot before it stops leading. This must be less than the lease duration. This is only applicable if leader election is enabled. | 10s ||
|| leader-elect-retry-period | The duration the clients should wait between attempting acquisition and renewal of a leadership. This is only applicable if leader election is enabled. | 2s ||
|| log-flush-frequency | Maximum number of seconds between log flushes | 5s ||
|| min-resync-period | The resync period in reflectors will be random between MinResyncPeriod and 2*MinResyncPeriod. | 12h0m0s ||
|| mirroring-endpointslice-updates-batch-period | The length of EndpointSlice updates batching period for EndpointSliceMirroring controller. Processing of EndpointSlice changes will be delayed by this duration to join them with potential upcoming updates and reduce the overall number of EndpointSlice updates. Larger number = higher endpoint programming latency, but lower number of endpoints revision generated |||
|| namespace-sync-period | 	The period for syncing namespace life-cycle updates | 5m0s ||
|| node-monitor-grace-period | Amount of time which we allow running Node to be unresponsive before marking it unhealthy. Must be N times more than kubelet's nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet to post node status. | 40s ||
|| node-monitor-period | 	The period for syncing NodeStatus in NodeController. | 5s ||
|| node-startup-grace-period  | Amount of time which we allow starting Node to be unresponsive before marking it unhealthy. | 1m0s ||
|| resource-quota-sync-period | The period for syncing quota usage status in the system | 5m0s ||
|| route-reconciliation-period  | The period for reconciling routes created for Nodes by cloud provider. | 10s ||
------

# kube-scheduler timer

| Category | Timer Name | Timer Description | Timer Default Values | Configuration Location | 
|----------|----------|----------|----------|----------|
|| authentication-token-webhook-cache-ttl | The duration to cache responses from the webhook token authenticator. | 10s ||
|| authorization-webhook-cache-authorized-ttl  | The duration to cache 'authorized' responses from the webhook authorizer. | 10s ||
|| authorization-webhook-cache-unauthorized-ttl | 	The duration to cache 'unauthorized' responses from the webhook authorizer. | 10s ||
|| leader-elect-lease-duration | 	The duration that non-leader candidates will wait after observing a leadership renewal until attempting to acquire leadership of a led but unrenewed leader slot. This is effectively the maximum duration that a leader can be stopped before it is replaced by another candidate. This is only applicable if leader election is enabled. | 15s ||
||leader-elect-renew-deadline | 	The interval between attempts by the acting master to renew a leadership slot before it stops leading. This must be less than the lease duration. This is only applicable if leader election is enabled. | 10s ||
|| leader-elect-retry-period | The duration the clients should wait between attempting acquisition and renewal of a leadership. This is only applicable if leader election is enabled. | 2s ||
|| log-flush-frequency | Maximum number of seconds between log flushes | 5s ||
---


# kube-proxy timer

| Category | Timer Name | Timer Description | Timer Default Values | Configuration Location | 
|----------|----------|----------|----------|----------|
|| conntrack-tcp-timeout-close-wait | NAT timeout for TCP connections in the CLOSE_WAIT state | 1h0m0s ||
|| conntrack-tcp-timeout-established | Idle timeout for established TCP connections (0 to leave as-is) | 24h0m0s ||
|| iptables-min-sync-period | The minimum interval of how often the iptables rules can be refreshed as endpoints and services change (e.g. '5s', '1m', '2h22m'). | 1s ||
|| iptables-sync-period  | The maximum interval of how often iptables rules are refreshed (e.g. '5s', '1m', '2h22m'). Must be greater than 0. | 30s ||
|| ipvs-sync-period | The maximum interval of how often ipvs rules are refreshed (e.g. '5s', '1m', '2h22m'). Must be greater than 0. | 30s ||
|| ipvs-tcp-timeout | The timeout for idle IPVS TCP connections, 0 to leave as-is. (e.g. '5s', '1m', '2h22m'). |||
|| ipvs-tcpfin-timeout | The timeout for IPVS TCP connections after receiving a FIN packet, 0 to leave as-is. (e.g. '5s', '1m', '2h22m'). |||
|| ipvs-udp-timeout | 	The timeout for IPVS UDP packets, 0 to leave as-is. (e.g. '5s', '1m', '2h22m'). |||
---



