Kubernetes Services
---
- [Endpoints and EndpointSlices](#endpoints-and-endpointslices)
  - [Endpoints](#endpoints)
  - [EndpointSlices](#endpointslices)


# Endpoints and EndpointSlices
## Endpoints

Pods are ephemeral. They are not designed to run forever, and when a Pod is terminated it cannot be brought back.

* Every time you add or remove a Pod from behind a Service, the entire EndPoints object gets updated, sent across the network, and is consumed by every node in the cluster.
* The larger the number of Pods in an Endpoints object, the larger the EndPoints object that is transferred to all the nodes in the cluster. The more frequently Pods are changed in your cluster also means the more frequently these transfers take place across your network.
* Every time a node receives an updated Endpoints object, it has to process this to configure new network rules. The larger the object, the more processing power is required. This applies to the api server as well. 

## EndpointSlices

Kubernetes' EndpointSlice API provides a way to track network endpoints within a Kubernetes cluster. EndpointSlices offer a more scalable and extensible alternative to Endpoints.

Endpoint Slices split the larger monolithic Endpoints object into smaller, consumable slices. Each slice holds a maximum of 100 endpoints. This means that any updates to Pods within the Endpoint Slice would result in a much smaller slice being sent over the network and consumed by Nodes in the cluster.