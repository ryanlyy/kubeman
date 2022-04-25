Container Runtime: containerd, cri-o and podman
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
- [NCS Features](#ncs-features)
- [conmon](#conmon)

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

buildah/podman as tool for image/build/push etc. job and then works with crio to do above.

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

| Catelog | Docker (docker) | Containerd(crictl) | CRIO(crictl)  | podman | containerd(ctr) |
|----------- |----------- |----------- |----------- |----------- |----------- |
| Container|attach |attach |attach | attach | task attach |
|N/A|N/A|N/A|N/A|auto-update |N/A|
| Image|build |N/A |buildah bud -t xx:yy -f Dockerfile . (same with docker build) | build | N/A |
| Container|commit |N/A |buildah commit cidxxxxx newimage:abc | commit | N/A |
| system |N/A|completion|completion| E | N/A|
| Container|cp |N/A | buildah copy cidxxxx './sandbox-config.json' '/root/sandbox-config.json' | cp | N/A |
| N/A|N/A|config|config| E | N/A |
| Container|create |create |create | create | create |
| Container|diff |N/A |podman diff imageid | diff | N/A |
| system|events |N/A |N/A | events | events |
| Container|exec |exec |exec | exec | task exec |
| Container|export |N/A |buildah commit --format oci cid oci-archive:./imagenm.tar  | export | eport |
|N/A|N/A|N/A|N/A|generate | N/A |
|N/A|N/A|N/A|N/A|healthcheck | N/A |
| Image|history |inspecti |inspecti | history | N/A |
| Image|images |images |images | images | images ls |
| Image|N/A |imageinfo |imagefsinfo | TBA | N/A |
| Image|import |N/A |N/A | import | import |
| system|info |info |info | info | N/A |
|N/A|N/A|N/A|N/A|init | N/A |
| Container|inspect |inspect/inspectp |inspect/inspectp | inspect | c info |
| Container|kill |N/A |N/A | kill | task kill |
| Image|load |N/A |buildah pull oci-archive:./oci-myecho.tar  | load | N/A |
| Image|login |N/A |buildah -u xxx login docker.io | login | N/A |
| Image|logout |N/A |buildah logout docker.io | logout | N/A |
| Container|logs |logs |logs | logs | N/A |
|N/A|N/A|N/A|N/A|manifest | N/A |
|N/A|N/A|N/A|N/A|mount | N/A |
| Container|pause|N/A|N/A|pause| task pause |
|N/A|N/A|N/A|N/A|play | N/A |
|N/A|N/A|N/A|N/A|pod | N/A |
| Container|port |port-forward |port-forward | port | N/A |
| Container|ps |ps/pods |ps/pods | ps | c ls |
| Image|pull |pull |pull | pull | pull |
| Image|push |N/A |buildah push | push | push |
| Container|rename |N/A |buildah rename | rename | N/A |
| Container|restart |N/A |N/A | restart | N/A |
| Container|rm |rm/rmp |rm/rmp | rm | rm |
| Image|rmi |rmi |rmi | rmi | image rm |
| Container|run |run/runp |run/runp | run | c run |
| Image|save |N/A |buildah push --format oci localhost/myecho:1.0 oci-archieve:./oci-myecho.tar | save | N/A |
| Image|search |N/A |N/A | search | N/A|
|N/A|N/A|N/A|N/A|secret | N/A |
| Container|start |start |start | start | task start  |
| Container|stats |stats |stats | stats | N/A |
| Container|stop |stop/stopp |stop/stopp | stop | N/A |
|N/A|N/A|N/A|N/A|system | N/A |
| Image|tag |N/A |buildah tag | tag | tag |
| Container|top |N/A |N/A | top | N/A |
|N/A|N/A|N/A|N/A|unmount | N/A |
| Container|unpause |N/A |N/A | unpause | N/A |
|N/A|N/A|N/A|N/A|unshare | N/A |
| Container|update |update |update | E | N/A |
| system|version |version |version | E | version |
|N/A|N/A|N/A|N/A|volume | N/A |
| Container|wait |N/A |N/A | wait | N/A |

NOTE: 
* ctr -n k8s.io task list: only list first task of each container
  ```bash
  [root@bcmt-edge-08 containerd]# ctr -n k8s.io task list
  TASK                                                                PID      STATUS    
  3ff050f94433a6039749739106153e4ef4f7e93ed8596953da328904e14b9414    14720    RUNNING
  f8f42ee430153286ae3f3d4e496e39a021fbf5af1db64ec34b184ab298fc61eb    16880    RUNNING
  97c16a17cef4f16136e6db9c6beffdf7f7cd88ad4085872ed2f69df2ce03487c    27873    RUNNING
  400487902e4988361ea8ee4e06cbc53e531367c3abbb83b4805eeb5ffd6fc25f    2824     RUNNING
  8c555b2ee6f57e93a8103c24d25eff3bf48a49b9ee1db2db3a42c6197bf533e7    14256    RUNNING
  1d8ceb8be21eab45179439ae40d6a16f10b55d2f39f668ceddd9bdfd923961a7    14198    RUNNING
  52aac01a3a7d66f9f61c163b4e0dc29a4f9024c4e751f592dbddb7d38c0b20b4    14831    RUNNING
  362cea9ebbcb264c3fcb4288b2a37dec8a66dac66ce14525d037c8bb961420b7    16621    RUNNING
  465dd78090b6f8e20f0cf12f2b34c0d7c7a0338b463bf838816ed0a5cd86ca6d    27721    RUNNING
  0c816b9c319bb6f11e40be5206d9d2dbcb62ce04e1c70bad0ec7e160dc8fa4be    2910     RUNNING
  c9e4c00d6071364dfca56ed3ee1498f13a112cc5aef6b8c70c850301d9b6cf0a    14044    RUNNING
  62e2a8750383d1b44eb7d97067de72ebd8465dcffa39639b6e5ea5003c54a162    17877    RUNNING
  921e5a5cfe02919ab0eba8619687be00dbd433dc2ba443903f58c77f740981a9    25714    RUNNING
  7a22a2ea111285a6928c23f9b2f9cc54b6d6bcf2546566387248135a8d0256c1    25948    RUNNING
  f931814cf8aa2b5867edb509488e6ae7b0b2eb74a55b9730cc42b125805cb899    25858    RUNNING
  332c31e04ea79cc0392489c7326fef366a356a334a22687577df86ee7f487f6b    15105    RUNNING
  bad0f88bdf2dcec0d3a23036876ef071b579feadb2322b0c023c60e205146503    17018    RUNNING
  9c410383094a5abaa2c10ad5abe7989bf9ad41b97389c08c64236bb114249def    15455    RUNNING
  d80bfdca47d34d08d566afdb304988efe5c07915c578e96b003f1a855970926a    17782    RUNNING
  a667c44e8fb56dd9ea92dcf011c35d5ad11a288374a4da3ab43301a79513cc45    25903    RUNNING
  b39a225bb4f56a1b76648803f09cfa8ff160ebd61e0078115221f0f363a33d66    14139    RUNNING
  9cb644f7ab17eab7d8fdbe86876f9a4f36c667f46e7a2c0fa9df3465b283eb26    15287    RUNNING
  c0c91fe42e80570690047d3186a94e83410ce8530de415d053eee29bc6271ea3    15323    RUNNING
  09c88a0d6893f6fa70c1175ee37e4815a28282b4599829b3e1064ae89e555978    15791    RUNNING
  25a623f1bebf161305cab8a151c720617eacb72d3eaf63ce272e5fa569426c56    27994    RUNNING
  9245c7790c7b7e876e0f81c678d51e4dbbfc7ded3c5d23f72e1aae5e3a1e8bd9    23254    RUNNING
  8cbc05e6ba4d707554bba9db417ce4577a37f20b158b482ae47f5f13403bfd91    23351    RUNNING
  274ae007230060625eff398f9ec868024fec6804380dfe8014c0e8e100e1e638    27755    RUNNING
  37e761883263d8b75f8ca6cdc06bf10b08d5ceff84133eefaa0916541cc02138    23023    RUNNING
  ab995290a7850c2c0dc18dba864eca20387f763e067c60bc59193304585359f0    15518    RUNNING
  ```
* ctr -n k8s.io task ps 52aac01a3a7d66f9f61c163b4e0dc29a4f9024c4e751f592dbddb7d38c0b20b4: show all tasks of specified container

  and you can list all exec task with ExecID information
  ```bash
  [root@bcmt-edge-08 containerd]# ctr -n k8s.io task ps 52aac01a3a7d66f9f61c163b4e0dc29a4f9024c4e751f592dbddb7d38c0b20b4
  PID      INFO
  2071     &ProcessDetails{ExecID:14831,XXX_unrecognized:[],}
  7198     -
  7403     &ProcessDetails{ExecID:36caee48e83e4afeef1e26dbde6805c2c4632e9685faa65bb2af846d7903d717,XXX_unrecognized:[],}
  11345    &ProcessDetails{ExecID:def,XXX_unrecognized:[],}
  14831    -
  14931    -
  14932    -
  14933    -
  14935    -
  23093    -
  23094    -
  23095    -
  23103    -
  23112    -
  23120    -
  23121    -
  23122    -
  23123    -
  23124    -
  23127    -
  23788    -
  23789    -
  23790    -
  23791    -
  23792    -
  23793    -
  23794    -
  [root@bcmt-edge-08 containerd]#
  ```
  Here **PID** means host node PID instead of container PID
  cat /proc/$pid/status | grep NSpid

  sometime you may meet "ctr: id 14831: already exists"; do:
  ```bash
  ctr -n k8s.io task delete -f --exec-id 14831 52aac01a3a7d66f9f61c163b4e0dc29a4f9024c4e751f592dbddb7d38c0b20b4
  ```


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

# NCS Features
https://jiradc2.ext.net.nokia.com/browse/NCS-270

NCS 22

In this feature, docker engine will be removed and containerd as CRI runtime interfaces.

BCMT admin container will be started by podman instead of docker anymore after this feature and using podman to push all infra + application images into local registry and then kubernetes/containerd can pull its images and start container.

in Openshift, crio is used w/ buildah


# conmon

An OCI container runtime monitor.

Conmon is a monitoring program and communication tool between a container manager (like Podman or CRI-O) and an OCI runtime (like runc or crun) for a single container.