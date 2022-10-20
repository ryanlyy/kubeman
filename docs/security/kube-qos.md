QoS
----

- [DSCP support](#dscp-support)
  - [Openshift - CaaS](#openshift---caas)
  - [Iptables - CaaS](#iptables---caas)
  - [Envoy and Istio - NET_ADMIN](#envoy-and-istio---net_admin)
  - [Application setsockopt(IP_TOS) - NET_ADMIN](#application-setsockoptip_tos---net_admin)


# DSCP support
## Openshift - CaaS
  
  https://cloud.redhat.com/blog/using-qos-dscp-in-openshift-container-platform
  ```yaml
    apiVersion: k8s.ovn.org/v1
    kind: EgressQoS
    metadata:
    name: default
    namespace: default
    spec:
    egress:
    - dscp: 40
        dstCIDR: 172.18.0.6/32
    - dscp: 50
        dstCIDR: 172.18.0.7/32
        podSelector:
        matchLabels:
            app: demo
  ```
## Iptables - CaaS

## Envoy and Istio - NET_ADMIN
  
  https://www.envoyproxy.io/docs/envoy/v1.23.1/api-v3/config/cluster/v3/cluster.proto.html?highlight=bindconfig

  https://www.envoyproxy.io/docs/envoy/v1.23.1/api-v3/config/core/v3/socket_option.proto#envoy-v3-api-msg-config-core-v3-socketoption

  https://github.com/istio/istio/issues/40397
  ```yaml
  apiVersion: networking.istio.io/v1alpha3
  kind: EnvoyFilter
  metadata:
    name: egress-dscp-socketoptions
  spec:
    configPatches:
    - applyTo: CLUSTER
      match:
        cluster:
          name: "outbound|443||traffic.foo.com"
      patch:
        operation: MERGE
        value:
          upstream_bind_config:
            source_address:
              address: "0.0.0.0"
              port_value: 0
            socket_options:
            - level: 0        #  0 for IPPROTO_IP
              name: 1         #  1 for IP_TOS
              int_value: 32  #IP_TOS is 72, and DSCP is 0x48
              state: STATE_PREBIND  #STATE_PREBIND is default, other 2 values are STATE_BOUND, STATE_LISTENING
  ```
  ```c
    int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
  ```
  cluster.upstream_bind_config.socket_options<level, name, int_value> <====> setsockopt<level, optname, optval>

  Examples of HTTP2 LB to set SND_BUFF and RCV_BUFF
  ```yaml
      clusters:
      - name: external-egress
        type: ORIGINAL_DST
        lb_policy: CLUSTER_PROVIDED
        connect_timeout:
          seconds: 10
        original_dst_lb_config:
          use_http_header: true
        cleanup_interval: {{ .Values.egress.idleConnTimeout | default 3600 }}s
        upstream_bind_config:
          source_address:
            address: X_HTTP2_IP
            port_value: 0
          socket_options:
          - description: "Set Send buffer size"
            level: 1
            name: 7
            int_value: {{ .Values.egress.sendBufferSize | int }}
            state: STATE_PREBIND
          - description: "Set Receive buffer size"
            level: 1
            name: 8
            int_value: {{ .Values.egress.recvBufferSize | int }}
            state: STATE_PREBIND

  ```

  Level:
    * #define SOL_SOCKET      1
      * #define SO_SNDBUF       7
      * #define SO_RCVBUF       8
      * #define SO_KEEPALIVE    9
      * #define SO_RCVTIMEO     20
      * #define SO_SNDTIMEO     21
    * #define IPPROTO_IP              0 
      * #define IP_TOS          1
      * #define IP_TTL          2
      * #define IP_MTU          14
    * #define IPPROTO_TCP             6
    * #define IPPROTO_UDP             17
    * #define IPPROTO_IPV6            41
    * #define IPPROTO_SCTP            132
    * 

```
IP_TOS (since Linux 1.0)
    Set or receive the Type-Of-Service (TOS) field that is sent with every IP packet originating from this socket. It is used to prioritize packets on the network. TOS is a byte. There are some standard TOS flags defined: IPTOS_LOWDELAY to minimize delays for interactive traffic, IPTOS_THROUGHPUT to optimize throughput, IPTOS_RELIABILITY to optimize for reliability, IPTOS_MINCOST should be used for "filler data" where slow transmission doesn't matter. At most one of these TOS values can be specified. Other bits are invalid and shall be cleared. Linux sends IPTOS_LOWDELAY datagrams first by default, but the exact behavior depends on the configured queueing discipline. Some high priority levels may require superuser privileges (the CAP_NET_ADMIN capability). The priority can also be set in a protocol independent way by the (SOL_SOCKET, SO_PRIORITY) socket option (see socket(7)). 

     /*
      * Definitions for IP type of service (ip_tos)
      */
      #define IPTOS_LOWDELAY          0x10
      #define IPTOS_THROUGHPUT        0x08
      #define IPTOS_RELIABILITY       0x04
      #define IPTOS_ECT               0x02    /* ECN-Capable Transport flag */
      #define IPTOS_CE                0x01    /* ECN-Congestion Experienced flag */

```

  * Socket Layer Options

    https://linux.die.net/man/7/socket

  * IP Layer Options:

      https://linux.die.net/man/7/ip
  
  * TCP Layer Options:
  
    https://linux.die.net/man/7/tcp
  
## Application setsockopt(IP_TOS) - NET_ADMIN