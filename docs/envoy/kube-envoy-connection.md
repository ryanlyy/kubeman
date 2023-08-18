Connection Handling
---

# Circuit Breaking Limit
* Cluster maximum connections: The maximum number of connections that Envoy will establish to all hosts in an upstream cluster
* Cluster maximum pending requests: The maximum number of requests that will be queued while waiting for a ready connection pool connection
* Cluster maximum requests: The maximum number of requests that can be outstanding to all hosts in a cluster at any given time
* Cluster maximum active retries: The maximum number of retries that can be outstanding to all hosts in a cluster at any given time
* Cluster maximum concurrent connection pools: The maximum number of connection pools that can be concurrently instantiated.

# Number of Conneciton Pool

Each host in each cluster will have **one or more connection pools**. If the cluster has a single explicit protocol configured, then the host may have only a single connection pool. However, if the cluster supports multiple upstream protocols, then unless it is using ALPN, **one connection pool per protocol** may be allocated

Separate connecton pools are also allocated:
* Routing Priority
* Socket Option
* Transport socket (TLS) options
* Downstream filter state objects

# HTTP/1.1 Connection Pool
The HTTP/1.1 connection pool acquires connections as needed to an upstream host (up to the **circuit breaking** limit). Requests are bound to connections as they become **available**:
* a connection is done processing a previous request 
* a new connection is ready to receive its first request
 
The HTTP/1.1 connection pool does not make use of pipelining so that only a single downstream request must be **reset** if the upstream connection is severed.

# HTTP/2
The HTTP/2 connection pool **multiplexes multiple requests over a single connection**, up to the limits imposed by 

* **max concurrent streams** 
* **max requests per connection**.
* Circuit Breaking

The HTTP/2 connection pool establishes **as many connections as are needed** to serve requests. With no limits, this will be only **a single connection**. 

If a **GOAWAY** frame is received or if the connection reaches the **maximum requests per connection** limit, the connection pool will drain the affected connection. 

Once a connection reaches its **maximum concurrent stream limit**, it will be marked as **busy** until a stream is available. 

New connections are established anytime there is a pending request without a connection that can be dispatched to (up to **circuit breaker** limits for connections). 

# HTTP3
The HTTP/3 connection pool **multiplexes multiple requests over a single connection**, up to the limits imposed by 
* **max concurrent streams**
* **max requests per connection**
 
The HTTP/3 connection pool establishes **as many connections as are needed** to serve requests. With no limits, this will be only a single connection. 

If a **GOAWAY** frame is received or if the connection reaches the **maximum requests per connection limit**, the connection pool will drain the affected connection. 

Once a connection reaches its **maximum concurrent stream limit**, it will be marked as **busy** until a stream is available. 

New connections are established anytime there is a pending request without a connection that can be dispatched to (up to **circuit breaker** limits for connections).

# TCP Connection Pool
For each downstream TCP new conneciton, new conneciton to upstream is issued.

```
max_connect_attempts
(UInt32Value) The maximum number of unsuccessful connection attempts that will be made before giving up. If the parameter is not specified, 1 connection attempt will be made.
```

```golang
Network::FilterStatus Filter::onNewConnection() {
  if (config_->maxDownstreamConnectionDuration()) {
    connection_duration_timer_ = read_callbacks_->connection().dispatcher().createTimer(
        [this]() -> void { onMaxDownstreamConnectionDuration(); });
    connection_duration_timer_->enableTimer(config_->maxDownstreamConnectionDuration().value());
  }

  ASSERT(upstream_ == nullptr);
  route_ = pickRoute();
  return establishUpstreamConnection();
}

Network::FilterStatus Filter::establishUpstreamConnection() {
  ...
  ENVOY_CONN_LOG(debug, "Creating connection to cluster {}", read_callbacks_->connection(),
                 cluster_name);

  const Upstream::ClusterInfoConstSharedPtr& cluster = thread_local_cluster->info();
  getStreamInfo().setUpstreamClusterInfo(cluster);

  // Check this here because the TCP conn pool will queue our request waiting for a connection that
  // will never be released.
  if (!cluster->resourceManager(Upstream::ResourcePriority::Default).connections().canCreate()) {
    getStreamInfo().setResponseFlag(StreamInfo::ResponseFlag::UpstreamOverflow);
    cluster->stats().upstream_cx_overflow_.inc();
    onInitFailure(UpstreamFailureReason::ResourceLimitExceeded);
    return Network::FilterStatus::StopIteration;
  }

  const uint32_t max_connect_attempts = config_->maxConnectAttempts();
  if (connect_attempts_ >= max_connect_attempts) {
    getStreamInfo().setResponseFlag(StreamInfo::ResponseFlag::UpstreamRetryLimitExceeded);
    cluster->stats().upstream_cx_connect_attempts_exceeded_.inc();
    onInitFailure(UpstreamFailureReason::ConnectFailed);
    return Network::FilterStatus::StopIteration;
  }

  auto& downstream_connection = read_callbacks_->connection();
  ...
}
```