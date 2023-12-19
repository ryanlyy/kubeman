Kubernetes affinity and taint
---

- [Node Affinity](#node-affinity)
  - [User Defined Constraints](#user-defined-constraints)


# Node Affinity
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: nodetype
            operator: In
            values:
            - infra
            - oam
            - reporting
```

# Pod Topology Spread Constraints
https://kubernetes.io/blog/2020/05/introducing-podtopologyspread/
https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/

use topology spread constraints to control how Pods are spread across your cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization

## Cluser Level Default Constraints Definition
Default topology spread constraints are applied to a Pod if, and only if:

* It doesn't define any constraints in its .spec.topologySpreadConstraints.
* It belongs to a Service, ReplicaSet, StatefulSet or ReplicationController

```yaml
---
apiVersion: kubescheduler.config.k8s.io/v1beta3
kind: KubeSchedulerConfiguration

profiles:
  - schedulerName: default-scheduler
    pluginConfig:
      - name: PodTopologySpread
        args:
          defaultConstraints:
            - maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: ScheduleAnyway
          defaultingType: List
```

## Built-in default constriants (v1.24 stable)
If you don't configure any cluster-level default constraints for pod topology spreading, then kube-scheduler acts as if you specified the following default topology constraints:

```yaml
defaultConstraints:
  - maxSkew: 3
    topologyKey: "kubernetes.io/hostname"
    whenUnsatisfiable: ScheduleAnyway
  - maxSkew: 5
    topologyKey: "topology.kubernetes.io/zone"
    whenUnsatisfiable: ScheduleAnyway
```

## CNF Specific Constraints
example:
```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  # Configure a topology spread constraint
  topologySpreadConstraints:
    - maxSkew: <integer>
      topologyKey: <string>
      whenUnsatisfiable: <string>
      labelSelector: <object>
      minDomains: <integer> # optional; beta since v1.25
      matchLabelKeys: <list> # optional; beta since v1.27
      nodeAffinityPolicy: [Honor|Ignore] # optional; beta since v1.26
      nodeTaintsPolicy: [Honor|Ignore] # optional; beta since v1.26
  ### other Pod fields go here
```
* maxSkew: the degree to which Pods may be unevenly distributed
* whenUnsatisfiable:
  * DoNotSchedule (default) - Hard
  * ScheduleAnyway  - soft
* topologyKey: node label
* labelSelector
  ```yaml
  matchLabels:
    component: redis
  matchExpressions:
    - { key: tier, operator: In, values: [cache] }
    - { key: environment, operator: NotIn, values: [dev] }
  ```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  # Configure a topology spread constraint
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: "topology.kubernetes.io/zone"
      whenUnsatisfiable: "ScheduleAnyway"
      labelSelector: 
        matchLabels:
          component: redis
        matchExpressions:
          - { key: tier, operator: In, values: [cache] }
          - { key: environment, operator: NotIn, values: [dev] }
    - maxSkew: 2
      topologyKey: "topology.kubernetes.io/zone"
      whenUnsatisfiable: "DoNotSchedule"
      labelSelector: 
        matchLabels:
          component: redis-2
        matchExpressions:
          - { key: tier, operator: In, values: [abc] }
          - { key: environment, operator: NotIn, values: [def] }
```
