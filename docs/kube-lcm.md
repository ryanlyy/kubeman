Kubernetes Upgrade Knowledge Base
---

- [Upgrade Basic](#upgrade-basic)
  - [Workload Resource](#workload-resource)
  - [Stateless Applications](#stateless-applications)
  - [Stateful Application](#stateful-application)
  - [Rolling Update](#rolling-update)
- [Pod Lifecycle](#pod-lifecycle)
- [Kubernetes Pod Termination Lifecycle](#kubernetes-pod-termination-lifecycle)
- [Deployment](#deployment)
  - [Upgrade](#upgrade)
    - [maxSurge and maxUnavailable](#maxsurge-and-maxunavailable)
  - [Rollback](#rollback)
- [Daemonset Upgrade & Rollback](#daemonset-upgrade--rollback)
  - [Upgrade](#upgrade-1)
  - [Rollback](#rollback-1)
- [Statefulset Upgrade](#statefulset-upgrade)
- [Help Upgrade](#help-upgrade)
  - [Resource Installation Order](#resource-installation-order)


# Upgrade Basic
## Workload Resource
* Deployments
  
  A Deployment provides declarative updates for Pods and ReplicaSets.

  Deployment == ReplicSet

* ReplicaSet
* StatefulSets
  
  StatefulSet is the workload API object used to manage stateful applications.

  Manages the deployment and scaling of a set of Pods, and provides   guarantees about the ordering and uniqueness of these Pods.
  
  Like a Deployment, a StatefulSet manages Pods that are based on an   identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier  that it maintains across any rescheduling.
  
  If you want to use storage volumes to provide persistence for your   workload, you can use a StatefulSet as part of the solution. Although   individual Pods in a StatefulSet are susceptible to failure, the persistent Pod identifiers make it easier to match existing volumes to the new Pods that replace any that have failed
  * Application Requirement
    * Stable, unique network identifiers.
    * Stable, persistent storage.
    * Ordered, graceful deployment and scaling.
    * Ordered, automated rolling updates.

   * Deployment and Scaling Guarantees

     For a StatefulSet with N replicas, when Pods are being deployed, they are created **sequentially**, in order from {0..N-1}.
     When Pods are being deleted, they are terminated in reverse order, from   {N-1..0}.

     Before a scaling operation is applied to a Pod, all of its predecessors must be Running and Ready.

     Before a Pod is terminated, all of its successors must be completely   shutdown.
  * Pod Management Policies
    * OrderedReady: next will not be created/terminated when last one is not ready/terminated.
      
      This is **default** policy

    * Parallel: only for scalling. will be create/terminate parallelly


    

* DaemonSet
  
  A DaemonSet ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created

* Jobs
* Garbage Collection
* TTL Controler for Finised Resource
* CronJob
* ReplicationController


## Stateless Applications
## Stateful Application
## Rolling Update
 Rolling updates allow Deployments' update to take place with **zero** downtime by incrementally updating Pods instances with new ones. The new Pods will be scheduled on Nodes with available resources

By default, the maximum number of Pods that can be unavailable during the update and the maximum number of new Pods that can be created, is **one**. Of course they can be configured.

# Pod Lifecycle



# Kubernetes Pod Termination Lifecycle
1. Pod is set to the “Terminating” State and removed from the endpoints list of all Services
   
   At this point, the pod stops getting new traffic

2. preStop Hook is executed
3. SIGTERM signal is sent to the pod 
4. Kubernetes waits for a grace period (.spec.terminationGracePeriod )
   
   At this point, Kubernetes waits for a specified time called the termination grace period. By default, this is 30 seconds. It’s important to note that this happens in parallel to the preStop hook and the SIGTERM signal. Kubernetes does not wait for the preStop hook to finish.

5. SIGKILL signal is sent to pod, and the pod is removed
 


# Deployment 
## Upgrade
  
  **Strategy**

  .spec.strategy specifies the strategy used to replace old Pods by new ones.   
  
  .spec.strategy.type can be: 
  * "Recreate" 
  
    All existing Pods are killed before new ones are created

    When terminating, creating is already fired

  * "RollingUpdate"
    
    The Deployment updates Pods in a rolling update fashion when .spec.strategy.type==RollingUpdate. You can specify **maxUnavailable and maxSurge** to control the rolling update process

    * MaxUnavailabe
      
      .spec.strategy.rollingUpdate.maxUnavailable is an **optional** field that specifies the maximum number of Pods that can be unavailable during the update process. The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The absolute number is calculated from percentage by rounding down. The value cannot be 0 if .spec.strategy.rollingUpdate.maxSurge is 0. **The default value is 25%**  (at least 75% are available).

      That is to say: 25% pod will be terminating immediately when update starts.

    * MaxSurge
      
      .spec.strategy.rollingUpdate.maxSurge is an **optional** field that specifies the maximum number of Pods that can be created over the desired number of Pods. The value can be an absolute number (for example, 5) or a percentage of desired Pods (for example, 10%). The value cannot be 0 if MaxUnavailable is 0. The absolute number is calculated from the percentage by rounding up. **The default value is 25%**

      when this value is set to 30%, the new ReplicaSet can be scaled up immediately when the rolling update starts, such that the total number of old and new Pods does not exceed 130% of desired Pods. Once old Pods have been killed, the new ReplicaSet can be scaled up further, ensuring that the total number of Pods running at any time during the update is at most 130% of desired Pods

      if MaxSurge == 0, then deployment update is same with sts and ds.
  
  "RollingUpdate"   is the **default** value

  When upgrading, it must make sure:

  It makes sure that **at least** [replicas - MaxUnaviliable] Pods are available and that **at max** [replicas + MaxSurge] Pods in total are available


### maxSurge and maxUnavailable

maxSugre is using Ceil and maxUnavailable is using Floor. But if both maxSurge and maxUnavailable is 0, then unavailable will be 1.

 ```golang   
        surge, err := intstrutil.GetScaledValueFromIntOrPercent(intstrutil.ValueOrDefault(maxSurge, intstrutil.FromInt(0)), int(desired), true)
        if err != nil {
                return 0, 0, err
        }
        unavailable, err := intstrutil.GetScaledValueFromIntOrPercent(intstrutil.ValueOrDefault(maxUnavailable, intstrutil.FromInt(0)), int(desired), false)
   
                if roundUp {
                        value = int(math.Ceil(float64(value) * (float64(total)) / 100))
                } else {
                        value = int(math.Floor(float64(value) * (float64(total)) / 100))
                }


     if surge == 0 && unavailable == 0 {
                // Validation should never allow the user to explicitly use zero values for both maxSurge
                // maxUnavailable. Due to rounding down maxUnavailable though, it may resolve to zero.
                // If both fenceposts resolve to zero, then we should set maxUnavailable to 1 on the
                // theory that surge might not work due to quota.
                unavailable = 1
        }
```


## Rollback
By default, all of the Deployment's rollout history is kept in the system so that you can rollback anytime you want (you can change that by modifying revision history limit).


# Daemonset Upgrade & Rollback
## Upgrade
  DaemonSet has two update strategy types:
  * OnDelete: 

    With OnDelete update strategy, after you update a DaemonSet template, new DaemonSet pods will only be created when you manually delete old DaemonSet pods. This is the same behavior of DaemonSet in Kubernetes version 1.5 or before.

  * RollingUpdate
   
    This is the **default** update strategy.

    With RollingUpdate update strategy, after you update a DaemonSet template, old DaemonSet pods will be killed, and new DaemonSet pods will be created automatically, in a controlled fashion. 
    
    **At most one pod** of the DaemonSet will be running on each node during the whole update process

    * maxUnavailable (default to 1): multiple ds upgrade same time if > 1 
      
      The maximum number of DaemonSet pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of total number of DaemonSet pods at the start of the update (ex: 10%)

## Rollback
```
kubectl rollout history daemonset <daemonset-name>
kubectl rollout undo daemonset <daemonset-name> --to-revision=<revision>
kubectl rollout status ds/<daemonset-name>
```
# Statefulset Upgrade
.spec.updateStrategy
* OnDelete: only works in onDelete Event
* 
 implements the legacy (1.6 and prior) behavior. When a StatefulSet's .spec.updateStrategy.type is set to OnDelete, the StatefulSet controller will not automatically update the Pods in a StatefulSet. Users must manually delete Pods to cause the controller to create new Pods that reflect modifications made to a StatefulSet's .spec.template

* RollingUpdate

  the StatefulSet controller will delete and recreate each Pod in the StatefulSet. It will proceed in the same order as Pod termination (**from the largest ordinal to the smallest**), updating each Pod one at a time. It will wait until an updated Pod is Running and Ready prior to updating its predecessor

* Partitions
  
  The RollingUpdate update strategy can be partitioned, by specifying a .spec.updateStrategy.rollingUpdate.partition. If a partition is specified, all Pods with an ordinal that is greater than or equal to the partition will be updated when the StatefulSet's .spec.template is updated. All Pods with an ordinal that is less than the partition will not be updated, and, even if they are deleted, they will be recreated at the previous version. If a StatefulSet's .spec.updateStrategy.rollingUpdate.partition is greater than its .spec.replicas, updates to its .spec.template will not be propagated to its Pods. In most cases you will not need to use a partition, but they are useful if you want to stage an update, roll out a canary, or perform a phased roll out

  default value is 0


# Help Upgrade

## Resource Installation Order


[Add support for ordering of resources within a chart for Custom Resources #8439 ](https://github.com/helm/helm/issues/8439)


```golang
 var InstallOrder KindSortOrder = []string{
	"Namespace",
	"NetworkPolicy",
	"ResourceQuota",
	"LimitRange",
	"PodSecurityPolicy",
	"PodDisruptionBudget",
	"Secret",
	"ConfigMap",
	"StorageClass",
	"PersistentVolume",
	"PersistentVolumeClaim",
	"ServiceAccount",
	"CustomResourceDefinition",
	"ClusterRole",
	"ClusterRoleList",
	"ClusterRoleBinding",
	"ClusterRoleBindingList",
	"Role",
	"RoleList",
	"RoleBinding",
	"RoleBindingList",
	"Service",
	"DaemonSet",
	"Pod",
	"ReplicationController",
	"ReplicaSet",
	"Deployment",
	"HorizontalPodAutoscaler",
	"StatefulSet",
	"Job",
	"CronJob",
	"Ingress",
	"APIService",
}

```