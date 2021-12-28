This page is related with kube helm knowledge
---

- [Parameters](#parameters)
  - [--wait](#--wait)
- [Helm Install](#helm-install)
- [Helm Upgrade](#helm-upgrade)
  - [Update w/ --force](#update-w---force)
  - [Update w/o --force](#update-wo---force)


# Parameters
## --wait
--wait: Waits until 
*	all Pods are in a ready state,
*	PVCs are bound, 
*	Deployments, StatefulSet, or ReplicaSet have minimum (Desired minus maxUnavailable) Pods in ready state
        * Statefulset must be ReadyReplics == replicas
*	Services have an IP address (and Ingress if a LoadBalancer)
Before marking the release as successful. It will wait for as long as the --timeout value. If timeout is reached, the release will be marked as FAILED. 

# Helm Install

Sequence execution...
* Pre-install anything in the crd/ directory.
* chartutil.ToRenderValues(chrt, vals, options, caps)
* i.createRelease(chrt, vals)
* rel.Hooks, manifestDoc, rel.Info.Notes, err = i.cfg.renderResources(chrt, valuesToRender, i.ReleaseName, i.OutputDir, i.SubNotes, i.UseReleaseName, i.IncludeCRDs, i.PostRenderer, i.DryRun)
* rel.SetStatus(release.StatusPendingInstall, "Initial install underway")
* resources, err := i.cfg.KubeClient.Build(bytes.NewBufferString(rel.Manifest), !i.DisableOpenAPIValidation)
* resources.Visit(setMetadataVisitor(rel.Name, rel.Namespace, true))
* resourceList, err := i.cfg.KubeClient.Build(bytes.NewBuffer(buf), true)
* i.cfg.execHook(rel, release.HookPreInstall, i.Timeout)
* i.cfg.KubeClient.Create(resourceList); err != nil && !apierrors.IsAlreadyExists(err)
* i.Wait && if  i.cfg.KubeClient.Wait(resources, i.Timeout);
   ```golang
   	return wait.PollImmediateUntil(2*time.Second, func() (bool, error) {
		for _, v := range created {
			ready, err := w.c.IsReady(ctx, v)
			if !ready || err != nil {
				return false, err
			}
		}
		return true, nil
	}, ctx.Done())
*  i.cfg.execHook(rel, release.HookPostInstall, i.Timeout)
   ```
  * w.c.IsReady
    * corev1.Pod --- ALL created workload Pod must be ready
      ```golang
      func (c *ReadyChecker) isPodReady(pod *corev1.Pod) bool {
	for _, c := range pod.Status.Conditions {
		if c.Type == corev1.PodReady && c.Status == corev1.ConditionTrue {
			return true
		}
	}
	c.log("Pod is not ready: %s/%s", pod.GetNamespace(), pod.GetName())
	return false
        }

      ```
      ```yaml
        - lastProbeTime: null
                lastTransitionTime: "2021-12-06T01:36:20Z"
                status: "True"
                type: Ready
      ```
    * batchv1.Job -- All created JOB must be complated successfully
      ```golang
      func (c *ReadyChecker) jobReady(job *batchv1.Job) bool {
	if job.Status.Failed > *job.Spec.BackoffLimit {
		c.log("Job is failed: %s/%s", job.GetNamespace(), job.GetName())
		return false
	}
	if job.Spec.Completions != nil && job.Status.Succeeded < *job.Spec.Completions {
		c.log("Job is not completed: %s/%s", job.GetNamespace(), job.GetName())
		return false
	}
	return true

      ```
    * appsv1.Deployment --- readyReplicas >= ReplicaSet - MaxUnavailable
      * Paused mark as Ready
 
      ```golang
        //here MaxUnavailable is from rollingUpgrade
        func (c *ReadyChecker) deploymentReady(rs *appsv1.ReplicaSet, dep *appsv1.Deployment) bool {
                expectedReady := *dep.Spec.Replicas - deploymentutil.MaxUnavailable(*dep)
                if !(rs.Status.ReadyReplicas >= expectedReady) {
                        c.log("Deployment is not ready: %s/%s. %d out of %d expected pods are ready", dep.Namespace, dep.Name, rs.Status.ReadyReplicas, expectedReady)
                        return false
                }
	return true
      ```
    * corev1.PersistentVolumeClaim --- ClaimBound
      ```golang
      func (c *ReadyChecker) volumeReady(v *corev1.PersistentVolumeClaim) bool {
	if v.Status.Phase != corev1.ClaimBound {
		c.log("PersistentVolumeClaim is not bound: %s/%s", v.GetNamespace(), v.GetName())
		return false
	}
	return true
      ```
    * corev1.Service --- ClusterIP or LoadBalancer IP is ready
      ```golang
      func (c *ReadyChecker) serviceReady(s *corev1.Service) bool {
	// ExternalName Services are external to cluster so helm shouldn't be checking to see if they're 'ready' (i.e. have an IP Set)
	if s.Spec.Type == corev1.ServiceTypeExternalName {
		return true
	}

	// Ensure that the service cluster IP is not empty
	if s.Spec.ClusterIP == "" {
		c.log("Service does not have cluster IP address: %s/%s", s.GetNamespace(), s.GetName())
		return false
	}

	// This checks if the service has a LoadBalancer and that balancer has an Ingress defined
	if s.Spec.Type == corev1.ServiceTypeLoadBalancer {
		// do not wait when at least 1 external IP is set
		if len(s.Spec.ExternalIPs) > 0 {
			c.log("Service %s/%s has external IP addresses (%v), marking as ready", s.GetNamespace(), s.GetName(), s.Spec.ExternalIPs)
			return true
		}

		if s.Status.LoadBalancer.Ingress == nil {
			c.log("Service does not have load balancer ingress IP address: %s/%s", s.GetNamespace(), s.GetName())
			return false
		}
	}

	return true
}
      ```
    * extensionsv1beta1.DaemonSet --- NumberReady >= replicas - maxUnavailable
      ```golang
      func (c *ReadyChecker) daemonSetReady(ds *appsv1.DaemonSet) bool {
	// If the update strategy is not a rolling update, there will be nothing to wait for
	if ds.Spec.UpdateStrategy.Type != appsv1.RollingUpdateDaemonSetStrategyType {
		return true
	}

	// Make sure all the updated pods have been scheduled
	if ds.Status.UpdatedNumberScheduled != ds.Status.DesiredNumberScheduled {
		c.log("DaemonSet is not ready: %s/%s. %d out of %d expected pods have been scheduled", ds.Namespace, ds.Name, ds.Status.UpdatedNumberScheduled, ds.Status.DesiredNumberScheduled)
		return false
	}
	maxUnavailable, err := intstr.GetValueFromIntOrPercent(ds.Spec.UpdateStrategy.RollingUpdate.MaxUnavailable, int(ds.Status.DesiredNumberScheduled), true)
	if err != nil {
		// If for some reason the value is invalid, set max unavailable to the
		// number of desired replicas. This is the same behavior as the
		// `MaxUnavailable` function in deploymentutil
		maxUnavailable = int(ds.Status.DesiredNumberScheduled)
	}

	expectedReady := int(ds.Status.DesiredNumberScheduled) - maxUnavailable
	if !(int(ds.Status.NumberReady) >= expectedReady) {
		c.log("DaemonSet is not ready: %s/%s. %d out of %d expected pods are ready", ds.Namespace, ds.Name, ds.Status.NumberReady, expectedReady)
		return false
	}
	return true
        }
      ```
    * apiextv1.CustomResourceDefinition
    * appsv1.StatefulSet -- ReadyReplicas == replicas
      ```golang
      func (c *ReadyChecker) statefulSetReady(sts *appsv1.StatefulSet) bool {
	// If the update strategy is not a rolling update, there will be nothing to wait for
	if sts.Spec.UpdateStrategy.Type != appsv1.RollingUpdateStatefulSetStrategyType {
		return true
	}

	// Dereference all the pointers because StatefulSets like them
	var partition int
	// 1 is the default for replicas if not set
	var replicas = 1
	// For some reason, even if the update strategy is a rolling update, the
	// actual rollingUpdate field can be nil. If it is, we can safely assume
	// there is no partition value
	if sts.Spec.UpdateStrategy.RollingUpdate != nil && sts.Spec.UpdateStrategy.RollingUpdate.Partition != nil {
		partition = int(*sts.Spec.UpdateStrategy.RollingUpdate.Partition)
	}
	if sts.Spec.Replicas != nil {
		replicas = int(*sts.Spec.Replicas)
	}

	// Because an update strategy can use partitioning, we need to calculate the
	// number of updated replicas we should have. For example, if the replicas
	// is set to 3 and the partition is 2, we'd expect only one pod to be
	// updated
	expectedReplicas := replicas - partition

	// Make sure all the updated pods have been scheduled
	if int(sts.Status.UpdatedReplicas) < expectedReplicas {
		c.log("StatefulSet is not ready: %s/%s. %d out of %d expected pods have been scheduled", sts.Namespace, sts.Name, sts.Status.UpdatedReplicas, expectedReplicas)
		return false
	}

	if int(sts.Status.ReadyReplicas) != replicas {
		c.log("StatefulSet is not ready: %s/%s. %d out of %d expected pods are ready", sts.Namespace, sts.Name, sts.Status.ReadyReplicas, replicas)
		return false
	}
	return true
        }
      ```
    * extensionsv1beta1.ReplicaSet
* !i.DisableHooks &&  i.cfg.execHook(rel, release.HookPostInstall, i.Timeout);
* rel.SetStatus(release.StatusDeployed, "Install complete")


# Helm Upgrade

https://blog.atomist.com/kubernetes-apply-replace-patch/

```golang
func (u *Upgrade) performUpgrade(originalRelease, upgradedRelease *release.Release) (*release.Release, error) {
            // Do a basic diff using gvk + name to figure out what new resources are being created so we can validate they don't already exist
        existingResources := make(map[string]bool)
        for _, r := range current {
                existingResources[objectKey(r)] = true
        }

        var toBeCreated kube.ResourceList
        for _, r := range target {
                if !existingResources[objectKey(r)] {
                        toBeCreated = append(toBeCreated, r)
                }
        }

        toBeUpdated, err := existingResourceConflict(toBeCreated, upgradedRelease.Name, upgradedRelease.Namespace)
        if err != nil {
                return nil, errors.Wrap(err, "rendered manifests contain a resource that already exists. Unable to continue with update")
        }
...
        u.cfg.Log("creating upgraded release for %s", upgradedRelease.Name)
        if err := u.cfg.Releases.Create(upgradedRelease); err != nil {
                return nil, err
        }
...
        // pre-upgrade hooks
        if !u.DisableHooks {
                if err := u.cfg.execHook(upgradedRelease, release.HookPreUpgrade, u.Timeout); err != nil {
...
        results, err := u.cfg.KubeClient.Update(current, target, u.Force)
...
        if u.Wait {
                if err := u.cfg.KubeClient.Wait(target, u.Timeout); err != nil {
...
        // post-upgrade hooks
        if !u.DisableHooks {
                if err := u.cfg.execHook(upgradedRelease, release.HookPostUpgrade, u.Timeout); err != nil {
                        return u.failRelease(upgradedRelease, results.Created, fmt.Errorf("post-upgrade hooks failed: %s", err))
                }
        }


}
```
* Create resource that don't already exist
* update resource that have been modified in the target
* delete resource that are not present in the target
```golang
//https://github.com/helm/helm/blob/main/pkg/kube/client.go
// Update takes the current list of objects and target list of objects and
// creates resources that don't already exist, updates resources that have been
// modified in the target configuration, and deletes resources from the current
// configuration that are not present in the target configuration. If an error
// occurs, a Result will still be returned with the error, containing all
// resource updates, creations, and deletions that were attempted. These can be
// used for cleanup or other logging purposes.
func (c *Client) Update(original, target ResourceList, force bool) (*Result, error) {
...
        // Since the resource does not exist, create it.
			if err := createResource(info); err != nil {
				return errors.Wrap(err, "failed to create resource")
			}
...
		if err := updateResource(c, info, originalInfo.Object, force); err != nil {
			c.Log("error updating the resource %q:\n\t %v", info.Name, err)
			updateErrors = append(updateErrors, err.Error())
		}
...
		if err := deleteResource(info); err != nil {
			c.Log("Failed to delete %q, err: %s", info.ObjectName(), err)
			continue
		}
```

helper = resource.NewHelper(target.Client, target.Mapping)

## Update w/ --force
```golang
obj, err = helper.Replace(target.Namespace, target.Name, true, target.Object)
{
        // Attempt to version the object based on client logic.
        version, err := metadataAccessor.ResourceVersion(obj)
        //resourceVersion: "105315489"
//if resourceVersion == "", then recreate it
 return m.replaceResource(c, m.Resource, namespace, name, obj, options)
    {
                return c.Put().
                NamespaceIfScoped(namespace, m.NamespaceScoped).
                Resource(resource).
                Name(name).
                VersionedParams(options, metav1.ParameterCodec).
                Body(obj).
                Do(context.TODO()).
                Get()
    }
}
```
## Update w/o --force
```golang
patch, patchType, err := createPatch(target, currentObj)
obj, err = helper.Patch(target.Namespace, target.Name, patchType, patch, nil)
{
            return m.RESTClient.Patch(pt).
                NamespaceIfScoped(namespace, m.NamespaceScoped).
                Resource(m.Resource).
                Name(name).
                VersionedParams(options, metav1.ParameterCodec).
                Body(data).
                Do(context.TODO()).
                Get()

}
```