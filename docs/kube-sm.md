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

# Sidecare Excludeport/IncludePort
```yaml
    sidecar.istio.io/interceptionMode: "{{ annotation .ObjectMeta `sidecar.istio.io/interceptionMode` .ProxyConfig.InterceptionMode }}",
    {{ with annotation .ObjectMeta `traffic.sidecar.istio.io/includeOutboundIPRanges` .Values.global.proxy.includeIPRanges }}traffic.sidecar.istio.io/includeOutboundIPRanges: "{{.}}",{{ end }}
    {{ with annotation .ObjectMeta `traffic.sidecar.istio.io/excludeOutboundIPRanges` .Values.global.proxy.excludeIPRanges }}traffic.sidecar.istio.io/excludeOutboundIPRanges: "{{.}}",{{ end }}
    traffic.sidecar.istio.io/includeInboundPorts: "{{ annotation .ObjectMeta `traffic.sidecar.istio.io/includeInboundPorts` `*` }}",
    traffic.sidecar.istio.io/excludeInboundPorts: "{{ excludeInboundPort (annotation .ObjectMeta `status.sidecar.istio.io/port` .Values.global.proxy.statusPort) (annotation .ObjectMeta `traffic.sidecar.istio.io/excludeInboundPorts` .Values.global.proxy.excludeInboundPorts) }}",
    {{ if or (isset .ObjectMeta.Annotations `traffic.sidecar.istio.io/includeOutboundPorts`) (ne (valueOrDefault .Values.global.proxy.includeOutboundPorts "") "") }}
    traffic.sidecar.istio.io/includeOutboundPorts: "{{ annotation .ObjectMeta `traffic.sidecar.istio.io/includeOutboundPorts` .Values.global.proxy.includeOutboundPorts }}",
    {{- end }}
    {{ if or (isset .ObjectMeta.Annotations `traffic.sidecar.istio.io/excludeOutboundPorts`) (ne .Values.global.proxy.excludeOutboundPorts "") }}
    traffic.sidecar.istio.io/excludeOutboundPorts: "{{ annotation .ObjectMeta `traffic.sidecar.istio.io/excludeOutboundPorts` .Values.global.proxy.excludeOutboundPorts }}",
    {{- end }}

```

# Example on resource and excludeport used by cnSBA
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Release.Name }}-cnsba-controller
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ .Release.Name }}-cnsba-controller
    version: {{ .Chart.Version }}
    app.kubernetes.io/name: {{ .Release.Name }}-cnsba-controller
    helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    release: {{ .Release.Name }}
spec:
  serviceName: {{ .Release.Name }}-cnsba-db-mesh
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .Release.Name }}-cnsba-controller
      app.kubernetes.io/instance: {{ .Release.Name }}
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-cnsba-controller
        version: {{ .Chart.Version }}
        app.kubernetes.io/name: {{ .Release.Name }}-cnsba-controller
        app.kubernetes.io/instance: {{ .Release.Name }}
        release: {{ .Release.Name }}
        vnfcType: {{ .Values.zts.vnfType}}
        serviceType: {{ .Values.zts.vnfName}}
      annotations:
  {{- if .Values.serviceMesh.proxy }}
        sidecar.istio.io/proxyCPU: "{{ .Values.serviceMesh.proxy.resources.requests.cpu }}"
        sidecar.istio.io/proxyCPULimit: "{{ .Values.serviceMesh.proxy.resources.limits.cpu }}"
        sidecar.istio.io/proxyMemory: "{{ .Values.serviceMesh.proxy.resources.requests.memory }}"
        sidecar.istio.io/proxyMemoryLimit: "{{ .Values.serviceMesh.proxy.resources.limits.memory }}"
  {{- end }}
        traffic.sidecar.istio.io/excludeOutboundPorts: {{ .Values.serviceMesh.excludeOutboundPorts }}

```
# Enable debug log level
```sh
nsenter -n -i -p -t 2799598 -- curl -X POST http://127.0.0.1:15000/logging?level=debug
```

# Envoy Dump Configuration
```sh
nsenter -n -i -p -t 2799598 -- curl http://127.0.0.1:15000/config_dump?include_eds
```

# Envoy Version used in Istio
```sh
nsenter -n -i -p -t 2799598 -- curl -s -X POST http://127.0.0.1:15000/server_info |egrep -A 6 "agent.*envoy"
  "user_agent_name": "envoy",
  "user_agent_build_version": {
   "version": {
    "major_number": 1,
    "minor_number": 18,
    "patch": 3
   },

```