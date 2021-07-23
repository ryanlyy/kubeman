Kubernetes Healcheck 
-------------

- [Types of health checks](#types-of-health-checks)
  - [Readiness](#readiness)
  - [Liveness](#liveness)
  - [Startup](#startup)
- [ProbeConfigruation](#probeconfigruation)
- [terminationGracePeriodSeconds](#terminationgraceperiodseconds)

# Types of health checks
* **readiness**: Readiness probes are designed to let Kubernetes know when your app is ready to serve traffic
* **liveness**:  Liveness probes let Kubernetes know if your app is alive or dead. If your app is dead, Kubernetes removes the Pod and starts a new one to replace it

## Readiness
The kubelet uses readiness probes to know when a container is ready to start accepting traffic. A Pod is considered ready when all of its containers are ready. One use of this signal is to control which Pods are used as backends for Services. When a Pod is not ready, it is removed from Service load balancers.

## Liveness
The kubelet uses liveness probes to know when to **restart a container**. For example, liveness probes could catch a deadlock, where an application is running, but unable to make progress. Restarting a container in such a state can help to make the application more available despite bugs.

 If the liveness probe fails, the kubelet **kills the container**, and the container is subjected to its **restart policy**

 That is to say: liveness is used to the process has no chance to restart for example: it is deadlock and does serve traffic, in this case, liveness can kill container, then kubelet can restart it or do nothing according to restartpolicy.

## Startup
The kubelet uses startup probes to know when a container application has started. If such a probe is configured, it disables liveness and readiness checks until it succeeds, making sure those probes don't interfere with the application startup. This can be used to adopt liveness checks on slow starting containers, avoiding them getting killed by the kubelet before they are up and running

# ProbeConfigruation
* initialDelaySeconds: Number of seconds after the container has started before liveness or readiness probes are initiated. Defaults to 0 seconds. Minimum value is 0.
* periodSeconds: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
* timeoutSeconds: Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1.
* successThreshold: Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness and startup Probes. Minimum value is 1.
* failureThreshold: When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready. Defaults to 3. Minimum value is 1.

# terminationGracePeriodSeconds
* Pod Level
  
  Prior to release 1.21, the pod-level terminationGracePeriodSeconds was used for terminating a container that failed its liveness or startup probe. This coupling was unintended and may have resulted in failed containers taking an unusually long time to restart when a pod-level terminationGracePeriodSeconds was set.

  **Container out of working duration** = failureThreshold * periodSeconds + terminationGracePeriodSeconds(Pod Level)

* Probe Level
  
  In 1.21, when the feature flag ProbeTerminationGracePeriod is enabled, users can specify a probe-level terminationGracePeriodSeconds as part of the probe specification. When the feature flag is enabled, and both a pod- and probe-level terminationGracePeriodSeconds are set, the kubelet will use the probe-level value.

  **Container out of working duration** = failureThreshold * periodSeconds + terminationGracePeriodSeconds(Probe Level)


* 
