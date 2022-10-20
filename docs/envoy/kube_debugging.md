This page includes some debugging cmd used in envoy 
---

- [How to find admin port](#how-to-find-admin-port)
- [How to show debug cmd help](#how-to-show-debug-cmd-help)
- [How to dump envoy running configuration](#how-to-dump-envoy-running-configuration)
- [How to enable log trace](#how-to-enable-log-trace)
- [How to print counter](#how-to-print-counter)

# How to find admin port
```yaml
bash-4.4$ cat /etc/envoy/config.yaml
node:
  id: htt2lb_envoy_0
  cluster: htt2lb_envoy
admin:
  access_log:
  - name: envoy.access_loggers.file
    filter:
      or_filter:
        filters:
          - status_code_filter:
              comparison:
                op: GE
                value:
                  default_value: 300
                  runtime_key: access_log.access_error.status
          - duration_filter:
              comparison:
                op: GE
                value:
                  default_value: 1000
                  runtime_key: access_log.access_error.duration
    typed_config:
      "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
      path: "/logstore/http2lbenvoylogs/access.log"
  address:
    socket_address:
      address: 192.168.34.118
      port_value: 9903
```

The admin ip and port will be:
```yaml
  address:
    socket_address:
      address: 192.168.34.118
      port_value: 9903
```

# How to show debug cmd help
```bash
bash-4.4$ curl http://192.168.34.118:9903/help
admin commands are:
  /: Admin home page
  /certs: print certs on machine
  /clusters: upstream cluster status
  /config_dump: dump current Envoy configs (experimental)
  /contention: dump current Envoy mutex contention stats (if enabled)
  /cpuprofiler: enable/disable the CPU profiler
  /drain_listeners: drain listeners
  /healthcheck/fail: cause the server to fail health checks
  /healthcheck/ok: cause the server to pass health checks
  /heapprofiler: enable/disable the heap profiler
  /help: print out list of admin commands
  /hot_restart_version: print the hot restart compatibility version
  /init_dump: dump current Envoy init manager information (experimental)
  /listeners: print listener info
  /logging: query/change logging levels
  /memory: print current allocation/heap usage
  /quitquitquit: exit the server
  /ready: print server state, return 200 if LIVE, otherwise return 503
  /reopen_logs: reopen access logs
  /reset_counters: reset all counters to zero
  /runtime: print runtime values
  /runtime_modify: modify runtime values
  /server_info: print server version/status information
  /stats: print server stats
  /stats/prometheus: print server stats in prometheus format
  /stats/recentlookups: Show recent stat-name lookups
  /stats/recentlookups/clear: clear list of stat-name lookups and counter
  /stats/recentlookups/disable: disable recording of reset stat-name lookup names
  /stats/recentlookups/enable: enable recording of reset stat-name lookup names

```

# How to dump envoy running configuration
```bash
bash-4.4$ curl http://192.168.34.118:9903/config_dump
```
[envoy configuration example](kube-envoy-config.yaml)

# How to enable log trace
```bash
curl -X POST http://192.168.34.118:9903//logging?level=off
curl -X POST http://<Management IP>:port/logging?level=debug
```

# How to print counter
```bash
bash-4.4$ curl http://192.168.34.118:9903/stats
bash-4.4$ curl http://192.168.34.118:9903/stats/prometheus
```
