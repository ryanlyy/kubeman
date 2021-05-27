This artical is used to summary all changes when docker is replaced by containerd, cri-o and podman
------------------
- [Deployment](#deployment)
- [Configuraiton](#configuraiton)
  - [Runtime Class](#runtime-class)
  - [kubelet container runtime](#kubelet-container-runtime)
  - [podman configuration](#podman-configuration)
- [Operation and Debugging](#operation-and-debugging)
  - [Unix Socket](#unix-socket)
  - [Images and Container Instance](#images-and-container-instance)
    - [crio rootfs](#crio-rootfs)
    - [podman rootfs](#podman-rootfs)
  - [CNI](#cni)
    - [Container CNI Example](#container-cni-example)
    - [CRIO CNI Example](#crio-cni-example)
  - [Command Comparision](#command-comparision)
  - [Container Tool Project](#container-tool-project)
  - [Debugging](#debugging)
  - [No Node Access Environment](#no-node-access-environment)
- [Application](#application)
- [NTAS Impact](#ntas-impact)

# Deployment

| Deployment | Docker | containerd | CRIO | poman |
|----------|----------|----------|----------|----------| 
|rpm | docker-ce-20.10.6-3.el8.x86_64 | containerd.io-1.4.4-3.1.el8.x86_64 | cri-o-1.21.0-4.1.el8.x86_64 | podman-3.1.2-1.el8.2.1.x86_64 |



# Configuraiton
## Runtime Class
Kubernetes v1.20 [stable]

Multiple runtime can be used by kebernetes
https://kubernetes.io/zh/docs/concepts/containers/runtime-class/

**Motivation**

You can set a different RuntimeClass between different Pods to provide **a balance of performance versus security**. For example, if part of your workload deserves a high level of information security assurance, you might choose to schedule those Pods so that they run in a container runtime that uses hardware virtualization. You'd then benefit from the extra isolation of the alternative runtime, at the expense of some additional overhead.

You can also use RuntimeClass to run different Pods with the same container runtime but with different settings.

## kubelet container runtime
Q: how to change kubelet remote runtime: docker, containerd, crio and podman???

A: update --container-runtime-endpoint with different unix socket defined in [Unix Socket](#unix-socket) to support different rumtime 

```
[root@foss-ssc-6 lib]# cd /usr/lib/systemd/system/kubelet.service.d
[root@foss-ssc-6 kubelet.service.d]# ls
10-kubeadm.conf
[root@foss-ssc-6 kubelet.service.d]# cat 10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
[root@foss-ssc-6 kubelet.service.d]# cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.4.1"
[root@foss-ssc-6 kubelet.service.d]#
```

## podman configuration
```
#  1. /usr/share/containers/containers.conf
#  2. /etc/containers/containers.conf
#  3. $HOME/.config/containers/containers.conf (Rootless containers ONLY)
```



# Operation and Debugging
## Unix Socket

|     | Docker | Containerd | crio | podman |
| --- | ------ | ---------- | ---- | ------ |
| Unix Socket | /var/run/docker.sock | /run/containerd/containerd.sock | /var/run/crio/crio.sock | N/A |
| crictl cmd | N/A |  crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps | crictl --runtime-endpoint unix:///var/run/d$crio/crio.sock ps | N/A |

## Images and Container Instance
|     | Docker | Containerd | crio | podman |
| --- | ------ | ---------- | ---- | ------ |
| Images | /var/lib/docker/image/overlay2/imagedb/content/sha256/  | /var/lib/containerd/io.containerd.content.v1.content/blobs/sha256  | /var/lib/containers/storage/overlay-images | /var/lib/containers/storage/overlay-images |
| Instance | ryanlyy/kdb/bin/get_container_rootfs.sh | /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots | [crio rootfs](#crio-rootfs) | [podman rootfs](#podman-rootfs) |

docker still can be used to do:
1. image build
2. image tag 
3. image push (keep registry same between docker and crio/podman/containerd)

continue studying buildah/podman on above tasks.
buildah/podman can work well with crio to do above.

### crio rootfs
```
cat /var//lib/containers/storage/overlay-containers/$(crictl --runtime-endpoint unix:///var/run/crio/crio.sock ps --no-trunc | grep 79ca67f9404e5 | awk '{ print $1 }')/userdata/state.json | jq -r '.annotations' | grep io.kubernetes.cri-o.MountPoint | awk -F ":" '{ print $2 }' | tr -s "," " "
```
here 79ca67f9404e5 is container id

### podman rootfs
```
cat /var/lib/containers/storage/overlay-containers/$(podman ps -q --no-trunc | grep 9514adf056d8)/userdata/config.json | jq -r '.root.path'
```

here 9514adf056d8 is container id

## CNI
|     | Docker | Containerd | crio | podman |
| --- | ------ | ---------- | ---- | ------ |
| config | /etc/cni/net.d | /etc/cni/net.d | /etc/cni/net.d | TBA |
| bin | /opt/cni/bin |/opt/cni/bin | /opt/cni/bin | TBA |
| cni | TBA | [Container CNI Example](#container-cni-example) | [CRIO CNI Example](#crio-cni-example) | TBA |

### Container CNI Example
```
{
  "cniVersion": "0.4.0",
  "name": "containerd-net",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni0",
      "isGateway": true,
      "ipMasq": true,
      "promiscMode": true,
      "ipam": {
        "type": "host-local",
        "ranges": [
          [{
            "subnet": "10.88.0.0/16"
          }],
          [{
            "subnet": "2001:4860:4860::/64"
          }]
        ],
        "routes": [
          { "dst": "0.0.0.0/0" },
          { "dst": "::/0" }
        ]
      }
    },
    {
      "type": "portmap",
      "capabilities": {"portMappings": true}
    }
  ]
}
```

### CRIO CNI Example
```
{
    "cniVersion": "0.3.1",
    "name": "crio",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "hairpinMode": true,
    "ipam": {
        "type": "host-local",
        "routes": [
            { "dst": "0.0.0.0/0" },
            { "dst": "1100:200::1/24" }
        ],
        "ranges": [
            [{ "subnet": "10.85.0.0/16" }],
            [{ "subnet": "1100:200::/24" }]
        ]
    }
}
```

## Command Comparision

| Catelog | Docker (docker) | Containerd(crictl) | CRIO(crictl)  | podman |
|----------- |----------- |----------- |----------- |----------- |
| Container|attach |attach |attach | attach |
|N/A|N/A|N/A|N/A|auto-update |
| Image|build |N/A |buildah bud -t xx:yy -f Dockerfile . (same with docker build) | build |
| Container|commit |N/A |buildah commit cidxxxxx newimage:abc | commit |
| system |N/A|completion|completion| E |
| Container|cp |N/A | buildah copy cidxxxx './sandbox-config.json' '/root/sandbox-config.json' | cp |
| N/A|N/A|config|config| E |
| Container|create |create |create | create |
| Container|diff |N/A |N/A | diff |
| system|events |N/A |N/A | events |
| Container|exec |exec |exec | exec |
| Container|export |N/A |N/A | export |
|N/A|N/A|N/A|N/A|generate |
|N/A|N/A|N/A|N/A|healthcheck |
| Image|history |inspecti |inspecti | history |
| Image|images |images |images | images |
| Image|N/A |imageinfo |imagefsinfo | TBA |
| Image|import |N/A |N/A | import |
| system|info |info |info | info |
|N/A|N/A|N/A|N/A|init |
| Container|inspect |inspect/inspectp |inspect/inspectp | inspect |
| Container|kill |N/A |N/A | kill |
| Image|load |N/A |podman load | load |
| Image|login |N/A |buildah -u xxx login docker.io | login |
| Image|logout |N/A |buildah logout docker.io | logout |
| Container|logs |logs |logs | logs |
|N/A|N/A|N/A|N/A|manifest |
|N/A|N/A|N/A|N/A|mount |
| Container|pause|N/A|N/A|pause|
|N/A|N/A|N/A|N/A|play |
|N/A|N/A|N/A|N/A|pod |
| Container|port |port-forward |port-forward | port |
| Container|ps |ps/pods |ps/pods | ps |
| Image|pull |pull |pull | pull |
| Image|push |N/A |buildah push | push |
| Container|rename |N/A |N/A | rename |
| Container|restart |N/A |N/A | restart |
| Container|rm |rm/rmp |rm/rmp | rm |
| Image|rmi |rmi |rmi | rmi |
| Container|run |run/runp |run/runp | run |
| Image|save |N/A |podman save | save |
| Image|search |N/A |N/A | search |
|N/A|N/A|N/A|N/A|secret |
| Container|start |start |start | start |
| Container|stats |stats |stats | stats |
| Container|stop |stop/stopp |stop/stopp | stop |
|N/A|N/A|N/A|N/A|system |
| Image|tag |N/A |buildah tag | tag |
| Container|top |N/A |N/A | top |
|N/A|N/A|N/A|N/A|unmount |
| Container|unpause |N/A |N/A | unpause |
|N/A|N/A|N/A|N/A|unshare |
| Container|update |update |update | E |
| system|version |version |version | E |
|N/A|N/A|N/A|N/A|volume |
| Container|wait |N/A |N/A | wait |

## Container Tool Project
https://github.com/containers

Tools include:
  * podman - For managing pods and container images (run, stop, start, ps, attach, exec, etc.) outside of the container engine
  * buildah - a tool that facilitates building Open Container Initiative (OCI) container images (openshift supported)
  * skopeo - Manage container image registries

##  Debugging
| Debugging | Docker | containerd | crio | podman | 
|--------|--------|--------|--------|--------|
|Build Image | | | | | 
|docker exec -u | | | | |
|

## No Node Access Environment


# Application 
| Impact | Docker | containerd | crio | podman | 
|--------|--------|--------|--------|--------|


# NTAS Impact
* CI Pipeline
* Mr Wolfe
* 
