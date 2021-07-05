Kubernetes LCM Operation

- [Deployment](#deployment)
- [Healing](#healing)
  - [Probe](#probe)
    - [Startup Probe](#startup-probe)
    - [Liveness Probe](#liveness-probe)
    - [Readyiness Probe](#readyiness-probe)
- [Upgrade](#upgrade)
- [Scalling](#scalling)


# Deployment
# Healing
## Probe

* **initialDelaySeconds**: Number of seconds after the container has started before liveness or readiness probes are initiated. Defaults to 0 seconds. Minimum value is 0.
* **periodSeconds**: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
* **timeoutSeconds**: Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1.
* **successThreshold**: Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness and startup Probes. Minimum value is 1.
* **failureThreshold**: When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready. Defaults to 3. Minimum value is 1.

### Startup Probe
The kubelet uses startup probes to know when a container application has started

If such a probe is configured, it disables liveness and readiness checks until it succeeds, making sure those probes don't interfere with the application startup

### Liveness Probe
The kubelet uses liveness probes to know when to restart a container

### Readyiness Probe
The kubelet uses readiness probes to know when a container is ready to start accepting traffic.  A Pod is considered ready when all of its containers are ready. One use of this signal is to control which Pods are used as backends for Services. When a Pod is not ready, it is removed from Service load balancers.

Readiness probes runs on the container during its whole lifecycle.


# Upgrade
# Scalling 