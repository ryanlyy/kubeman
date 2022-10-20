Scheduling Preemption and Eviction
---

- [Resource Manager and Controller](#resource-manager-and-controller)
  - [CPU Manager](#cpu-manager)
  - [Memory Manager](#memory-manager)
  - [topology-manager](#topology-manager)
- [Kubernetes Scheduler](#kubernetes-scheduler)
- [Assigning Pods to Nodes](#assigning-pods-to-nodes)
  - [NodeSelector](#nodeselector)
  - [Node isolation/restriction](#node-isolationrestriction)
  - [Affinity and anti-affinity](#affinity-and-anti-affinity)
    - [Node affinity](#node-affinity)
    - [Node affinity per scheduling profile](#node-affinity-per-scheduling-profile)
    - [Inter-pod affinity and anti-affinity](#inter-pod-affinity-and-anti-affinity)
    - [Namespace selector](#namespace-selector)
    - [nodeName](#nodename)
- [Pod Overhead](#pod-overhead)
- [Taints and Tolerations](#taints-and-tolerations)
- [Scheduling Framework](#scheduling-framework)
- [Scheduler Performance Tuning](#scheduler-performance-tuning)
- [Resource Bin Packing for Extended Resources](#resource-bin-packing-for-extended-resources)
- [Pod Disruption](#pod-disruption)
  - [Pod Priority and Preemption](#pod-priority-and-preemption)
  - [Node-pressure Eviction](#node-pressure-eviction)
  - [API-initiated Eviction](#api-initiated-eviction)
- [Topology Spread Constraints](#topology-spread-constraints)

https://kubernetes.io/docs/concepts/scheduling-eviction/


# Resource Manager and Controller
## CPU Manager
Kubernetes v1.12 [beta]

## Memory Manager
Kubernetes v1.22 [beta]

The Memory Manager is a Hint Provider, and it provides topology hints for the Topology Manager which then aligns the requested resources according to these topology hints. It also enforces cgroups (i.e. cpuset.mems) for pods

The administrator must provide reserved-memory when Static policy is configured in KubeletConfiguration
* MemoryManager: true|false
* memoryManagerPolicy: static|none 
* reservedMemory: 
  * - numaNode: 0
  *   limit:
  *     memory:
  *   request:
  *     memory:
## topology-manager
Kubernetes v1.18 [beta]

# Kubernetes Scheduler
# Assigning Pods to Nodes
## NodeSelector
## Node isolation/restriction
## Affinity and anti-affinity
### Node affinity
### Node affinity per scheduling profile
### Inter-pod affinity and anti-affinity
### Namespace selector
### nodeName
# Pod Overhead
# Taints and Tolerations
# Scheduling Framework
# Scheduler Performance Tuning
# Resource Bin Packing for Extended Resources
# Pod Disruption
## Pod Priority and Preemption
## Node-pressure Eviction
## API-initiated Eviction
# Topology Spread Constraints