Kubernetes Based Service Mesh (ISTIO)

# Istio Sidecar Auto Injection
* Namespace Level
  ```sh
  kubectl label namespace thrif-demo istio-injection=enabled

  thrift-demo                     Active   9d      istio-injection=enabled,kubernetes.io/metadata.name=thrift-demo
  ```
* Pod Level
  ```yaml
    metadata:
    annotations:
      sidecar.istio.io/inject: "true"
  ```
# Sidecar Resource Customization
```yaml
resources:
  {{- if or (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU`) (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory`) (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPULimit`) (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemoryLimit`) }}
            {{- if or (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU`) (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory`) }}
              requests:
                {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU`) -}}
                cpu: "{{ index .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU` }}"
                {{ end }}
                {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory`) -}}
                memory: "{{ index .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory` }}"
                {{ end }}
            {{- end }}
            {{- if or (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPULimit`) (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemoryLimit`) }}
              limits:
                {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPULimit`) -}}
                cpu: "{{ index .ObjectMeta.Annotations `sidecar.istio.io/proxyCPULimit` }}"
                {{ end }}
                {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemoryLimit`) -}}
                memory: "{{ index .ObjectMeta.Annotations `sidecar.istio.io/proxyMemoryLimit` }}"
                {{ end }}
            {{- end }}
          {{- else }}
            {{- if .Values.global.proxy.resources }}
              {{ toYaml .Values.global.proxy.resources | indent 6 }}
            {{- end }}

```

# Enable debug log level
```sh
nsenter -n -i -p -t 2799598 -- curl -X POST http://127.0.0.1:15000/logging?level=debug
```

# Envoy Dump Configuration
```sh
nsenter -n -i -p -t 2799598 -- curl http://127.0.0.1:15000/config_dump?include_eds
```