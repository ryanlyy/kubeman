Kubernetes Loadbalancer - metalLB
---

- [Overview](#overview)
- [Concept](#concept)
  - [Address Allocation](#address-allocation)
  - [External Announcement](#external-announcement)
- [Layer 2 mode](#layer-2-mode)
  - [Limitations](#limitations)
- [BGP mode](#bgp-mode)
  - [Limitations](#limitations-1)


# Overview

Kubernetes does not offer an implementation of network load balancers (**Services of type LoadBalancer**) for bare-metal clusters

GCP, AWS, Azure does provide IaaS platform related Load Balancer

“NodePort” and “externalIPs” services are left for kube in bare metal cluster but they have significant downsides for production usage

So metalLB is coming... but now (2022/3/24) still BETA

# Concept

MetalLB **hooks** into your Kubernetes cluster, and provides a network load-balancer implementation. it allows you to create Kubernetes services of **type LoadBalancer** in clusters 

## Address Allocation

* IP address Pools, metalLB will take care of assigning and unassigning individual address as servcies com and go which services defines **Services of type LoadBalancer**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.1.240-192.168.1.250

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    peers:
    - peer-address: 10.0.0.1
      peer-asn: 64501
      my-asn: 64500
    address-pools:
    - name: default
      protocol: bgp
      addresses:
      - 192.168.10.0/24
```

## External Announcement
After MetalLB has assigned an external IP address to a service, it needs to make the network beyond the cluster aware that the IP “lives” in the cluster. MetalLB uses standard routing protocols to achieve this: **ARP, NDP, or BGP**.

* Layer2 mode (ARP/NDP)
  one machine in the cluster owns all IP addresses which is discovered using ARP/NDP protocol by next hop gateway

* BGP
  All machines establish BGP session with nearby routes

  # Layer 2 mode 
  The major advantage of the layer 2 mode is its universality: it will work on any Ethernet network, with no special hardware required, not even fancy routers.

  Active/Standyb mode using memberlist(gossip)

  all traffic for a service IP goes to one node. From there, kube-proxy spreads the traffic to all the service’s pods.

## Limitations
* single-node bottlenecking
* potentially slow failover: Peer/nexthop can't quickly handle Gartuitious ARP/NDP package then incoming packet will go to failure node still.

# BGP mode
  In BGP mode, each node in your cluster establishes a BGP peering session with your network routers, and uses that peering session to advertise the IPs of external cluster services.

  After the packets arrive at the node, kube-proxy is responsible for the final hop of traffic routing, to get the packets to one specific pod in the service.

  Load balancer mode:

  * based on per-connection: Per-connection means that all the packets for a single TCP or UDP session will be directed to a single machine in your cluster. The traffic spreading only happens between different connections, not for packets within one connection.
  * based on packet hash:  For each packet, they extract some of the fields, and use those as a “seed” to deterministically pick one of the possible backends. If all the fields are the same, the same backend will be chosen
   
   The exact hashing methods available depend on the router hardware and software. Two typical options are 3-tuple and 5-tuple hashing. 3-tuple uses (protocol, source-ip, dest-ip) as the key, meaning that all packets between two unique IPs will go to the same backend. 5-tuple hashing adds the source and destination ports to the mix, which allows different connections from the same clients to be spread around the cluster.

   ## Limitations
   * The biggest downside is that BGP-based load balancing does not react gracefully to changes in the backend set for an address. What this means is that when a cluster node goes down, you should expect all active connections to your service to be broken (users will see “Connection reset by peer”).
   * The problem is that the hashes used in routers are usually not stable, so whenever the size of the backend set changes (for example when a node’s BGP session goes down), existing connections will be rehashed effectively randomly, which means that the majority of existing connections will end up suddenly being forwarded to a different backend, one that has no knowledge of the connection in question.


   * 