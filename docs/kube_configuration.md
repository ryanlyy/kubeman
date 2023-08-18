this page is used to summary the kubernetes configuration by default
---

- [Kube Configuration](#kube-configuration)
- [Cluster Configuration](#cluster-configuration)
  - [Configuration used by kubeadmin init](#configuration-used-by-kubeadmin-init)
    - [Init default configuration](#init-default-configuration)
  - [Configuration used by kubeadm join command](#configuration-used-by-kubeadm-join-command)
- [Kubelet Configuration](#kubelet-configuration)
  - [Init default Configuration](#init-default-configuration-1)
  - [Running Configuration](#running-configuration)
  - [Running kubelet commond line parameters](#running-kubelet-commond-line-parameters)
- [KubeProxy Configuraiton](#kubeproxy-configuraiton)
  - [Init default configuraiton](#init-default-configuraiton)
- [Kube-apiserver Configuration](#kube-apiserver-configuration)
- [Kube-Scheduler Configuration](#kube-scheduler-configuration)
- [Kube-Controller Configuration](#kube-controller-configuration)
- [CoreDNS Configuration](#coredns-configuration)


# Kube Configuration

```bash
kubectl config view
```
```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://10.67.26.196:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
```

```bash
root@tstbed-1:~/.kube# cat ~/.kube/config 
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EWXpNREF5TlRRek9Wb1hEVE16TURZeU56QXlOVFF6T1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT0ZkCmVHelcyWjlacXB4b2pPNUoyWlZrbng4QzQyWVNkWk5JbnVXckVTZE42S1JTVWhpYXRmRTJxUy83Q1FQRmZ2ekEKbkxnVmJ0dnhXSFBDRE1wOW14SVduMitkdmZ1RVNMbXdUVkVTOGk5d0xLZ2VTalNlQS9IWld2NStLSFNCbTlBVQowaWxWaUVkdGZwSUNZOFJZVitkRDEvZ0NVWVd1akUrWXkvcW92TUpVcm9EQnU0VEI1YTJzMTdnMVZuQmN1OVpRCm1UZjZSY2w4K09Ya1VSZEZTR1FZTkxVb1k0OEFzTkQrU1JkQlVTRXN5UGR1elcrWXMySXViV2FaM2R2YjA1RngKRU5wN21TcS9tZ0ZxR0dlNlNPNktaL1UyR0tNSzYxejZ6emtuMkgvVnFuQWU0QjA5NnlZWG1MbS9tcHJGZm5hZwpRMUFWU0N4V3o2VWswMGFRNXA4Q0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZLMXJQVGw4U1dETG5TYVp5NXk4aEphcjJSclRNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBTnkxa0tldXRSMCtyeUtEazFHMApUSHd2K3daeU1aVDRuWGZKZzB6eGViWkl4MUE3SzMyWUh4a3p6Z3gyeTVOelZhZ3VTR0lGcTJaUzhMYkprV2luClNPQnFKUCtXaFRQRHlBZjlseFRoUk9OOUNNZStWY3Y3UTc4ZE5iTVRsY2VwbzVzR0lSUGlRd1FVTkU1eUxzNCsKcFE2SjYyS3hPdXdnNXhmNUVoMCttYm9LeWx3T0k3S1RSNG9Gb2NZWG1sMGZpVlE5a0lFOGlKOGM3VndWL3hhZAp4N3R6cEJIN0pRTjYwZDlrVmJIQWVYSWVhWGVhQ2s5bXJmT2NWMSs5Tnl0cVRnVE44RWs0OVlha29LQTh0OTFVCjVBdWNaYWhxendCVm9OSnJIYys3UUQ2cWF1aU93ejV0SVZ6blBVV2xqenRHSCtweTlPRS91ZTZkc3FmYzNSb2kKVUQ0PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://10.67.26.196:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJRHBSSWcxTzBtTE13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBMk16QXdNalUwTXpsYUZ3MHlOREEyTWprd01qVTBORE5hTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW9UK1VDZy84OXg3VjZaaTUKQTAwRHRFeG82aEs5OExNRXFSU09QSkh2NHFQMklzN29UakVBbWxkQzVRcUNnUklyQnFLOWxhVVAyUVlJQmJUYQptVEdmT1N3VFd0RndOYWpNM09acXljK1lJZEgwVjJCWWMycU1zYWozQ21EL0QxZ0VWVTRQWHo2RHBTblphNmNLCkRLV09wcHpWOHkvRGVlTEExbWRwdjd0SXlueUJTNmwxTmhTTnpjREkwTjhJdmdWOTlhUWJrL29hWnZQVFpWOUsKMU5TQXlLVTV1UUFOVXFPK0lYMHFuV3pPZUxsM0tKSUgvZ1FTRCtkT21XakNVclpQc3lIWVkxZkhsaEJZb01ScgpmcEE0SU9EN1AxQzU1TDFaWCtybTBYNmVLeG9GcDdEdHY0RjQyMkh6RmU3R2lJSzhjVHpSaHU2K0RqRUJWOE1xCmMxSEQ1d0lEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JTdGF6MDVmRWxneTUwbW1jdWN2SVNXcTlrYQowekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBSGdLWWN6cHN5dU9UblNYOWtGWVlQN2lPTWZwelcwbmJzc2x4CjJmZzRPUDcyUXpsQTAyNVRVUS9KWlRzcGNsUDliaUF4MGtoTEZsR3drWHUwR095cHpDSUdBZmkzdFp2VmN6ZHcKSVFnWjg3aHdZSmN6TkxWRTZDNXROZTdOVCsvSmpmRlJMYk1CenhnOUhNeVR1MHJWNnRtUGxZL1lsRGNWcWdwYgpJSFg2Z1ZnbUgxRGpISUNSUnpqWm03Qkw0THU5QjcvTTUvWjM4azdseHJ3S2hyYk9uMGdzcGNkaUZGYkhLNXA0CnVCSHhQcG44K0hvYmJyY2gwVUdlT0ZQbGp1cFFjVmFtTWgrZW5oQmNIL0hqd0Q1b3Bma1Mwb0lBZThvS01abC8KZ2pxSGJxSmxObURzS3A5b0V0MXpaak1MY0hXaXNpNjQxeFU5MTdRM1d5QzNtNkhmNFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBb1QrVUNnLzg5eDdWNlppNUEwMER0RXhvNmhLOThMTUVxUlNPUEpIdjRxUDJJczdvClRqRUFtbGRDNVFxQ2dSSXJCcUs5bGFVUDJRWUlCYlRhbVRHZk9Td1RXdEZ3TmFqTTNPWnF5YytZSWRIMFYyQlkKYzJxTXNhajNDbUQvRDFnRVZVNFBYejZEcFNuWmE2Y0tES1dPcHB6Vjh5L0RlZUxBMW1kcHY3dEl5bnlCUzZsMQpOaFNOemNESTBOOEl2Z1Y5OWFRYmsvb2FadlBUWlY5SzFOU0F5S1U1dVFBTlVxTytJWDBxbld6T2VMbDNLSklICi9nUVNEK2RPbVdqQ1VyWlBzeUhZWTFmSGxoQllvTVJyZnBBNElPRDdQMUM1NUwxWlgrcm0wWDZlS3hvRnA3RHQKdjRGNDIySHpGZTdHaUlLOGNUelJodTYrRGpFQlY4TXFjMUhENXdJREFRQUJBb0lCQUJ3R0xyWm8vTy85L2ZOeApSWVpiVmk5NXNDb3VRN0NYakZIT2JzSDhJeExpcUI1NGswc3puUVUxOFR4WlRVRWRaVGpzQThNRVF2TFc1NElHCllvK0pYa0RUZGpHc2dMSHl1bGdSKzdGRFVROWZxL1dibXdQRUd0dXRuL0cvMWRSVzJibnhyUjVDZ1NLdFdVb3EKWjhhMjUwbnhyQVZ0NGExSFNYaDUxSmtyOVlTclJEWVZ5MUdURGI4U09hRWs5RGtLSlVxM2hZV2UyNkNOWVQvdAozeEJNcXhWeU1UcDhnY0JmdHZiZVFFZUxjREpadTZhZXVaM0UvV2JjOGc4WkRuTjNRNlZHbWlUSXVjUlQ0clI3Cm5WcEIxaHhmMUNhaTZYZUlDVG1YckhWVjNYZ0ZHMjRxUGJxUEhyMElRM3hPeU16Rm8vbUtWb2crazlJOExpVGkKVVVqakl3RUNnWUVBeXlkMWFwYWtnQnQ1TTgySVJicDVaOWdiZEMzenlIU0kwNHVYTERxMVZwMExkWklDbit6bQpseHVVQjdlV1p5YXh3aHhqRUZtUjRnOWJKc3JTVG55LzhaL0dyNDJVd3BuR3hoS0tJb0k3WWtQdlRkQzY5OStECjFkQmhGVWxQV29EKzZEKzMwT0FNY2ZUVDVMd0piU3hUQXpXS05lMWcva1QwTGQxL0hkakVFOEVDZ1lFQXl6R0MKUlZnTHlCQTZ0Y3dKQW5EY2l1RnFRdHhmdnZmVm9SdW4zZW1sdUJTT2cxeVVEaC84WHBIL2M1YzVLeGNDbFNzOApsUmpiZTZpL3ZVVThNeGYxTi8xSGU5Umt5YzRzdkRld1BmbXlqU3ZoY0NiL2UyUXNnWUJURU8rbi9JMnUrVEVCCktWbjU5d2Q3WTdPZENyUmZMUUNVUTRhOUsvZHlxM0pZRElnZElhY0NnWUI1cE5UdnorZ01OV2NybDZSRGJGY0oKMFNNUE8veS9TTmd0STJhUHUwK2QzMGRmVE9CNWRsYlVvRlRSRWlMaS9RNXZWcVFTeEM5UUZ6WFRVcHIvR0QrdQpwS2RKc3hNaU93WUUwRkVhUExUbU1CdDRrc1dCYXJyOEtsd1hiT0F4SnhCN2JMdmFQRzMzUmt3aXFGMVVtN2ZSCk1odmlFcE9EYlRKd3pESXpZdnAxZ1FLQmdBd1lSVlhWV05ZdXlSL2JKa29qNTZ6SW9DZWNzSUpRaEVIVHdKay8KK0NKTjd2RzR5QU5UT2hWekFVNmpHTDhNM3BWOGZsMnRuaHJ0UDRTSG8zNnpGV0NnemVsOENnZk5JdktOS2d0MgpXbjkydGpPVHpxOU1saTJiTXRhV1BWeVdIbTBzMHBIZ2pqVjdGNGdtdjlsTVJVSUxmOGZKTkdkeWtqdk1VWnRsCldyNlBBb0dBVmZPbWlKUk1kUmhGYS9BSzM0c3VuUnlPV1BiZUxvaDRyZzFtWk9QNUpqVzdCL1JZS2lCc3liRlUKUHVLY3p2SWEvd2hFVGgyeVlSZTZuUE5iOU1FcW5UdDhzeUtmMlA3NkN3SE9ubjg0SCtQT0tYODEwT3E2OTRtawo4a0hpVllJVFRVc3h6OE5QaWJHZlBNWVVaelVkOFhzdFByamtVeFpma0lkYnV4L2p2aWM9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
```
# Cluster Configuration

## Configuration used by kubeadmin init

### Init default configuration

```bash
kubeadm config print init-defaults
```
```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
localAPIEndpoint:
  advertiseAddress: 1.2.3.4
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: node
  taints: null
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kubernetesVersion: 1.27.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}

```

## Configuration used by kubeadm join command

```bash
kubeadm config print join-defaults
```

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: kube-apiserver:6443
    token: abcdef.0123456789abcdef
    unsafeSkipCAVerification: true
  timeout: 5m0s
  tlsBootstrapToken: abcdef.0123456789abcdef
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: tstbed-1
  taints: null
```
# Kubelet Configuration


## Init default Configuration

```bash
kubeadm config print init-defaults --component-configs KubeletConfiguration
```
```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerRuntimeEndpoint: ""
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
logging:
  flushFrequency: 0
  options:
    json:
      infoBufferSize: "0"
  verbosity: 0
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
```

## Running Configuration
```yaml
[root@hpg10ncs-hpg10ncs-masterbm-1 ~ (Backup)]# cat $(ps -ef | grep kubelet | grep "\--config" | awk '{ print $10 }' | cut -d "=" -f2)
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
featureGates:
  LocalStorageCapacityIsolationFSQuotaMonitoring: true
  TopologyManager: false
  MemoryManager: false
rotateCertificates: true
nodeStatusUpdateFrequency: 10s
clusterDNS: ['10.254.0.10']
clusterDomain: "cluster.local"
staticPodPath: "/etc/kubernetes/manifests"
tlsCertFile: "/etc/kubernetes/ssl/kubelet.pem"
tlsPrivateKeyFile: "/etc/kubernetes/ssl/kubelet-key.pem"
tlsMinVersion: "VersionTLS12"
tlsCipherSuites: [TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_GCM_SHA384]
address: "172.31.7.10"
cgroupDriver: systemd
failSwapOn: false
streamingConnectionIdleTimeout: 60m
protectKernelDefaults: true
makeIPTablesUtilChains: true
eventRecordQPS: 0
authorization:
  mode: Webhook
authentication:
  x509:
    clientCAFile: "/etc/kubernetes/ssl/ca.pem"
  anonymous:
    enabled: false
evictionPressureTransitionPeriod: "60s"
evictionMaxPodGracePeriod: 120
evictionHard:
  memory.available: 19318Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
  imagefs.available: 10%
  pid.available: "10%"
evictionSoft:
  memory.available: 57956Mi
  pid.available: "15%"
evictionMinimumReclaim:
  memory.available: 57956Mi
  pid.available: "4096"
evictionSoftGracePeriod:
  memory.available: "30s"
  pid.available: "30s"
kernelMemcgNotification: true
systemReserved:
  memory: 62464Mi
cpuManagerPolicy: none
containerLogMaxFiles: 3
containerLogMaxSize: 100Mi
imageGCHighThresholdPercent: 75
imageGCLowThresholdPercent: 70
podPidsLimit: 4096
[root@hpg10ncs-hpg10ncs-masterbm-1 ~ (Backup)]# 
```

## Running kubelet commond line parameters
```bash
[root@hpg10ncs-hpg10ncs-masterbm-1 ~ (Backup)]# ps -ef | grep kubelet | grep "\--config" | awk '{for ( i = 9; i <= NF; i++) {printf "%s\n", $i}; printf "\n" }'
--kubeconfig=/etc/kubernetes/kubelet.kubeconfig
--config=/etc/kubernetes/kubelet-config.yml
--register-node=true
--hostname-override=hpg10ncs-hpg10ncs-masterbm-1
--node-labels=is_control=true,is_worker=false,is_edge=false,is_storage=false,bcmt_storage_node=true,rook_storage=false,rook_storage2=false,cpu_pooler_active=false,dynamic_local_storage_node=false,local_storage_node=false,topology.kubernetes.io/region=hpg10ncs-hpg10ncs,topology.kubernetes.io/zone=zone1
--register-with-taints=is_control=true:NoExecute
--node-ip=172.31.7.10
--cloud-provider=
--hostname-override=hpg10ncs-hpg10ncs-masterbm-1
--container-runtime=remote
--container-runtime-endpoint=unix:///run/containerd/containerd.sock
--v=1

[root@hpg10ncs-hpg10ncs-masterbm-1 ~ (Backup)]# 
```
# KubeProxy Configuraiton

## Init default configuraiton
```bash
```
```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
bindAddressHardFail: false
clientConnection:
  acceptContentTypes: ""
  burst: 0
  contentType: ""
  kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
  qps: 0
clusterCIDR: ""
configSyncPeriod: 0s
conntrack:
  maxPerCore: null
  min: null
  tcpCloseWaitTimeout: null
  tcpEstablishedTimeout: null
detectLocal:
  bridgeInterface: ""
  interfaceNamePrefix: ""
detectLocalMode: ""
enableProfiling: false
healthzBindAddress: ""
hostnameOverride: ""
iptables:
  localhostNodePorts: null
  masqueradeAll: false
  masqueradeBit: null
  minSyncPeriod: 0s
  syncPeriod: 0s
ipvs:
  excludeCIDRs: null
  minSyncPeriod: 0s
  scheduler: ""
  strictARP: false
  syncPeriod: 0s
  tcpFinTimeout: 0s
  tcpTimeout: 0s
  udpTimeout: 0s
metricsBindAddress: ""
mode: ""
nodePortAddresses: null
oomScoreAdj: null
portRange: ""
showHiddenMetricsForVersion: ""
winkernel:
  enableDSR: false
  forwardHealthCheckVip: false
  networkName: ""
  rootHnsEndpointName: ""
  sourceVip: ""
```
# Kube-apiserver Configuration
#@ extension-apiserver-authentication 
```yaml
root@tstbed-1:~# kubectl get cm -n kube-system extension-apiserver-authentication -o yaml
apiVersion: v1
data:
  client-ca-file: |
    -----BEGIN CERTIFICATE-----
    MIIC/jCCAeagAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
    cm5ldGVzMB4XDTIzMDYzMDAyNTQzOVoXDTMzMDYyNzAyNTQzOVowFTETMBEGA1UE
    AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOFd
    eGzW2Z9ZqpxojO5J2ZVknx8C42YSdZNInuWrESdN6KRSUhiatfE2qS/7CQPFfvzA
    nLgVbtvxWHPCDMp9mxIWn2+dvfuESLmwTVES8i9wLKgeSjSeA/HZWv5+KHSBm9AU
    0ilViEdtfpICY8RYV+dD1/gCUYWujE+Yy/qovMJUroDBu4TB5a2s17g1VnBcu9ZQ
    mTf6Rcl8+OXkURdFSGQYNLUoY48AsND+SRdBUSEsyPduzW+Ys2IubWaZ3dvb05Fx
    ENp7mSq/mgFqGGe6SO6KZ/U2GKMK61z6zzkn2H/VqnAe4B096yYXmLm/mprFfnag
    Q1AVSCxWz6Uk00aQ5p8CAwEAAaNZMFcwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
    /wQFMAMBAf8wHQYDVR0OBBYEFK1rPTl8SWDLnSaZy5y8hJar2RrTMBUGA1UdEQQO
    MAyCCmt1YmVybmV0ZXMwDQYJKoZIhvcNAQELBQADggEBANy1kKeutR0+ryKDk1G0
    THwv+wZyMZT4nXfJg0zxebZIx1A7K32YHxkzzgx2y5NzVaguSGIFq2ZS8LbJkWin
    SOBqJP+WhTPDyAf9lxThRON9CMe+Vcv7Q78dNbMTlcepo5sGIRPiQwQUNE5yLs4+
    pQ6J62KxOuwg5xf5Eh0+mboKylwOI7KTR4oFocYXml0fiVQ9kIE8iJ8c7VwV/xad
    x7tzpBH7JQN60d9kVbHAeXIeaXeaCk9mrfOcV1+9NytqTgTN8Ek49YakoKA8t91U
    5AucZahqzwBVoNJrHc+7QD6qauiOwz5tIVznPUWljztGH+py9OE/ue6dsqfc3Roi
    UD4=
    -----END CERTIFICATE-----
  requestheader-allowed-names: '["front-proxy-client"]'
  requestheader-client-ca-file: |
    -----BEGIN CERTIFICATE-----
    MIIDCjCCAfKgAwIBAgIBADANBgkqhkiG9w0BAQsFADAZMRcwFQYDVQQDEw5mcm9u
    dC1wcm94eS1jYTAeFw0yMzA2MzAwMjU0NDBaFw0zMzA2MjcwMjU0NDBaMBkxFzAV
    BgNVBAMTDmZyb250LXByb3h5LWNhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
    CgKCAQEAmgmsIC6WL4Rabl2o/DPHYqJVJpy9a7jKh8hhFUbdLdlngL+pV1pF1m1S
    MjvzA0swt8til1NPJYfoFGBXVN5SZpTzoVvdJvlaepS8f/P5l66xtzI+JgTjg+ga
    tUCL372SBbPA59FlDCARSHyunooYTh7Oj6WRQ1pboAcxv+74b7JIkPvqobctl2BK
    EeT4vBhUej/ZqQPIbzLyDcnWIas1K6uKWXMcJHuSdcrP4XM8Io2wMTBL1PxMhcB0
    oBYSnO5zevsPkNAtCIF2b6DtzLK1hyuzaeZtYVmHEemzMaeP8FUbL0NFC8EXvMgO
    JNXekKkzmp5TwuKn99ZAdC1s7bFClQIDAQABo10wWzAOBgNVHQ8BAf8EBAMCAqQw
    DwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUxddP1nyaxXzjTUmRfYbOasYSCVUw
    GQYDVR0RBBIwEIIOZnJvbnQtcHJveHktY2EwDQYJKoZIhvcNAQELBQADggEBAJHQ
    f3SoS/GoPFTd6NLZL+7JoAHL5moigyWq3qENXh6v4vlTJye1LrOOp1vG30TTotOv
    Fxs25Yje+cWGhYMofIqgQELI5fFdyR72NZa3Om2UdWDMsR2mE1NTiT6EEHimEYo4
    Vu+RH1p3Zy0TP2R1du2cMYXZmfWx7rebUHD2PrK/mbHfuiAyzEOU5LF51B/QQ63u
    K7MQ/gnthsONNC0kgdU9TnUnJyrnrPVkdZXFQxM+2mG5M/5XgJ2wYfd9fDT6n/1o
    SJr5pQHbNFT7trJOH5EUry0l97kRQ/WVqeJnp5rs2V90+CBNM0HGz9l2dpXhMaH/
    XUOoXT75NamqeQu34E4=
    -----END CERTIFICATE-----
  requestheader-extra-headers-prefix: '["X-Remote-Extra-"]'
  requestheader-group-headers: '["X-Remote-Group"]'
  requestheader-username-headers: '["X-Remote-User"]'
kind: ConfigMap
metadata:
  creationTimestamp: "2023-06-30T02:54:52Z"
  name: extension-apiserver-authentication
  namespace: kube-system
  resourceVersion: "27"
  uid: fdda1f36-319a-436a-884c-8852e6640a53
```

# Kube-Scheduler Configuration

# Kube-Controller Configuration

# CoreDNS Configuration

```yaml
root@tstbed-1:~# kubectl get cm coredns -n kube-system  -o yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2023-06-30T02:54:57Z"
  name: coredns
  namespace: kube-system
  resourceVersion: "264"
  uid: 181514dc-3e0e-48bb-b6a8-0c57e26d0348
```

