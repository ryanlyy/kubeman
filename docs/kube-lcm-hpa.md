Kubernetes Scaling HPA
---

- [Overview](#overview)
- [How HPA works](#how-hpa-works)
- [HPA API](#hpa-api)
- [Scaling on  metrics](#scaling-on--metrics)
  - [Resource metrics (metrics.k8s.io) provided by metrics-server](#resource-metrics-metricsk8sio-provided-by-metrics-server)
  - [Customer Metrics (custom.metrics.k8s.io) provided by metrics solution vendor](#customer-metrics-custommetricsk8sio-provided-by-metrics-solution-vendor)
  - [External metreics (external.metrics.k8s.io) provided by custom metrics adpator](#external-metreics-externalmetricsk8sio-provided-by-custom-metrics-adpator)
  - [Monitoring Pipeline](#monitoring-pipeline)
    - [cAdvisor + Prometheus](#cadvisor--prometheus)
- [HPA Walkthrough](#hpa-walkthrough)
  - [Autoscaling on resource metrics (CPU)](#autoscaling-on-resource-metrics-cpu)
  - [Autoscaling on multiple metrics and custom metrics](#autoscaling-on-multiple-metrics-and-custom-metrics)
    - [pod metrics](#pod-metrics)
    - [object metrics](#object-metrics)
    - [Autoscaling on metrics not related to Kubernetes objects](#autoscaling-on-metrics-not-related-to-kubernetes-objects)
- [References](#references)

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

# Overview
In Kubernetes, a HorizontalPodAutoscaler automatically updates a workload resource (such as a Deployment or StatefulSet), with the aim of automatically scaling the workload to match demand except DaemonSet

Autoscaling controller: Parts of kube-controler-manager
running within the Kubernetes **control plane** as "control loop", periodically adjusts the desired scale of its target (for example, a Deployment) to match observed metrics such as average **CPU utilization**, average **memory utilization**, or any other **custom metric** you specify

* Horizontal Scaling
  * Deploying more pod
* Vertical Scaling
  * assigning more resource(cpu,memory)
  
--horizontal-pod-autoscaler-sync-period parameter to the kube-controller-manager (and the default interval is 15 seconds).

# How HPA works
* Once during each period, the controller manager queries the resource utilization against the metrics specified in each HorizontalPodAutoscaler definition
* Find the **target resource** defined by the **scaleTargetRef**
* Then selects the pods based on the target resource's .spec.selector labels, and obtains the metrics from either the resource metrics API (for per-pod resource metrics), or the custom metrics API (for all other metrics).
* For per-pod resource metrics (like CPU), 
* 


HPA is namespaced

# HPA API

* V1: Only support CPU Utilization
  ```
  targetCPUUtilizationPercentage (int32)
    target average CPU utilization (represented as a percentage of requested CPU) over all the pods; if not specified the default autoscaling policy will be used
  ```
  https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v1/

* V2
  * scaleTargetRef (CrossVersionObjectReference)
    * kind (Deployment|Statefulset)
    * name (workload name in this namespace on that kind)
    * apiVersion(kind API Version)
  * behavior (HorizontalPodAutoscalerBehavior)
    * scaleUp
    * scaleDown
  * metrics: metrics contains the specifications for which to use to calculate the desired replica count (the maximum replica count across all metrics will be used). The desired replica count is calculated multiplying the ratio between the target value and the current value by the current number of pods
    * type (metrics source): ContainerResource|External|Object|Pods|Resource

      * resource (ResourceMetricSource) -- per pod
        * name(string): name of resource in questions
          * cpu
          * memory
        * target(MetricTarget)
          * type (string): Utilization|Value|AverageValue
          * averageUtilization (only valid for Resource metric source type(i.e: cpu/memory))
          * averageValue
          * value

      * containerResource(**ContainerResourceMetricSource**) 
        * container(string): container name of scaling target
        * name(string): the name of the resource in question
          * cpu
          * memory
        * target(MetricTarget): target Values of the given metrics
          * type: Utilization|Value|Average
          * averageUtilization (only valid for Resource metric source type(i.e: cpu/memory))
          * averageValue
          * value
        NOTE: per container feature-gate **HPAContainerMetrics** must be enabled

      * pods (PodsMetricSource)
        * metric
          * name(string): namve of given metric
          * selector(LabelSelecotor)
        * target(MetricTarget): target Values of the given metrics
          * type: Utilization|Value|Average
          * averageUtilization (only valid for Resource metric source type(i.e: cpu/memory))
          * averageValue
          * value

      * object (ObjectMetricSource)
        * describedOject (CrossVersionObjectReference)
          * kind
          * name
          * apiVersion
        * metric
          * name(string): namve of given metric
          * selector(LabelSelecotor)
        * target(MetricTarget): target Values of the given metrics
          * type: Utilization|Value|Average
          * averageUtilization (only valid for Resource metric source type(i.e: cpu/memory))
          * averageValue
          * value

      * external (**ExternalMetricSource**)
        * metric
          * name(string): namve of given metric
          * selector(LabelSelecotor)
        * target(MetricTarget): target Values of the given metrics
          * type: Utilization|Value|Average
          * averageUtilization (only valid for Resource metric source type(i.e: cpu/memory))
          * averageValue
          * value

NOTE: selector is the string-encoded form of a standard kubernetes label selector for the given metric When set, it is passed as an additional parameter to the **metrics server** for more specific metrics scoping. When unset, just the metricName will be used to gather metrics.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Pods
    pods:
      metric:
        name: packets-per-second
      target:
        type: AverageValue
        averageValue: 1k
  - type: Object
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        name: main-route
      target:
        type: Value
        value: 10k
```
https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v2/

# Scaling on  metrics
FEATURE STATE: Kubernetes v1.23 [stable] 

Provided that you use the **autoscaling/v2** API version, you can configure a HorizontalPodAutoscaler to scale based on a custom metric (that is not built in to Kubernetes or any Kubernetes component). The HorizontalPodAutoscaler controller then queries for these **custom metrics** from the Kubernetes API.

API:
* For **resource metrics**, this is the **metrics.k8s.io** API, generally provided by **metrics-server**. It can be launched as a cluster add-on
* For **custom metrics**, this is the **custom.metrics.k8s.io** API. It's provided by **"adapter" API servers** provided by metrics solution vendors. Check with your metrics pipeline to see if there is a **Kubernetes metrics adapter** available
* For **external metrics**, this is the **external.metrics.k8s.io** API. It may be provided by the **custom metrics adapters** provided above

## Resource metrics (metrics.k8s.io) provided by metrics-server
## Customer Metrics (custom.metrics.k8s.io) provided by metrics solution vendor
proposes an API that the Horizontal Pod Autoscaler can use to access **arbitrary metrics**

* Root API: **/apis/custom-metrics/v1alpha1**
* **/{object-type}/{object-name}/{metric-name...}**: retrieve the given metric for the given non-namespaced object (e.g. Node, PersistentVolume)
* **/{object-type}/*/{metric-name...}**: retrieve the given metric for all non-namespaced objects of the given type
* **/{object-type}/*/{metric-name...}?labelSelector=foo**: retrieve the given metric for all non-namespaced objects of the given type matching the given label selector
* **/namespaces/{namespace-name}/{object-type}/{object-name}/{metric-name...}**: retrieve the given metric for the given namespaced object
* **/namespaces/{namespace-name}/{object-type}/*/{metric-name...}**: retrieve the given metric for all namespaced objects of the given type
* **/namespaces/{namespace-name}/{object-type}/*/{metric-name...}?labelSelector=foo**: retrieve the given metric for all namespaced objects of the given type matching the given label selector
* **/namespaces/{namespace-name}/metrics/{metric-name}**: retrieve the given metric which describes the given namespace.

## External metreics (external.metrics.k8s.io) provided by custom metrics adpator
HPA v2 API extension proposal introduces new External metric type for autoscaling based on metrics coming from outside of Kubernetes cluster

* /apis/external.metrics.k8s.io/v1beta1/namespaces/<namespace_name>/<metric_name>?labelSelector=<selector>

external refers to a global metric that is not associated with any Kubernetes object. It allows autoscaling based on information coming from components running outside of cluster (for example length of queue in cloud messaging service, or QPS from loadbalancer running outside of cluster).

ExternalMetricSource indicates how to scale on a metric not associated with any Kubernetes object (for example length of queue in cloud messaging service, or QPS from loadbalancer running outside of cluster).


## Monitoring Pipeline
A monitoring pipeline used for collecting various metrics from the system and exposing them to end-users, as well as to the Horizontal Pod Autoscaler (for custom metrics) and Infrastore via adapters. Users can choose from many monitoring system vendors, or run none at all. In open-source, Kubernetes will not ship with a **monitoring pipeline**, but third-party options will be easy to install. We expect that such pipelines will typically consist of a per-node agent and a cluster-level aggregator.
![Custom Metrics Architecture](../pics/CustomMetrics.JPG)

Data collected by the monitoring pipeline may contain any sub- or superset of the following groups of metrics:

* core system metrics
* non-core system metrics
* service metrics from user application containers
* service metrics from Kubernetes infrastructure containers; these metrics are exposed using Prometheus instrumentation

monitoring pipeline would  have to create a stateless **API adapter** that **pulls** the custom metrics from the monitoring pipeline and **exposes** them to the Horizontal Pod Autoscaler
* cAdvisor + Heapster + InfluxDB (or any other sink)
* cAdvisor + collectd + Heapster
* **cAdvisor + Prometheus**
* snapd + Heapster
* snapd + SNAP cluster-level agent
* Sysdig

### cAdvisor + Prometheus

* core and non-core system metrics from cAdvisor
* **service metrics exposed by containers** via HTTP handler in Prometheus format
* [optional] metrics about node itself from Node Exporter (a Prometheus component)

# HPA Walkthrough
## Autoscaling on resource metrics (CPU)
* metrics-server shall be installed using https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml w/ updated parameter "- --kubelet-insecure-tls"
```
E0402 01:50:02.220719       1 scraper.go:140] "Failed to scrape node" err="Get \"https://10.67.26.198:10250/metrics/resource\": x509: cannot validate certificate for 10.67.26.198 because it doesn't contain any IP SANs" node="eksa-2"
I0402 01:50:08.446220       1 server.go:187] "Failed probe" probe="metric-storage-ready" err="no metrics to serve"
```
* https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough

```bash
root@eksa-2:~/hpa# kubectl get hpa php-apache --watch
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   0%/50%    1         10        1          4m25s
php-apache   Deployment/php-apache   65%/50%   1         10        1          5m1s
php-apache   Deployment/php-apache   250%/50%   1         10        2          5m16s
php-apache   Deployment/php-apache   156%/50%   1         10        4          5m31s
php-apache   Deployment/php-apache   120%/50%   1         10        5          5m46s
php-apache   Deployment/php-apache   57%/50%    1         10        5          6m1s
php-apache   Deployment/php-apache   55%/50%    1         10        5          6m16s
php-apache   Deployment/php-apache   59%/50%    1         10        5          6m31s
php-apache   Deployment/php-apache   62%/50%    1         10        6          6m46s
php-apache   Deployment/php-apache   53%/50%    1         10        6          7m1s
php-apache   Deployment/php-apache   48%/50%    1         10        6          7m16s
```
**Autoscaling the replicas may take a few minutes (around 5minutes)**

## Autoscaling on multiple metrics and custom metrics
There are two other types of metrics, both of which are considered custom metrics: **pod metrics and object metrics**. These metrics may have names which are **cluster specific**, and require a more advanced **cluster monitoring setup**.

### pod metrics
These metrics describe **Pods**, and are averaged together across Pods and compared with a target value to determine the replica count. They work much like resource metrics, except that they only support a target type of **AverageValue**.


### object metrics

### Autoscaling on metrics not related to Kubernetes objects

# References
* https://towardsdatascience.com/kubernetes-hpa-with-custom-metrics-from-prometheus-9ffc201991e
* https://www.ibm.com/docs/en/cloud-private/3.1.2?topic=tp-horizontal-pod-auto-scaling-by-using-custom-metrics
* https://sysdig.com/blog/kubernetes-autoscaler/
* https://faun.pub/writing-custom-metrics-exporter-for-kubernetes-hpa-8a2601a53386
* https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
