This page is related with volumes
---

- [tmpfs](#tmpfs)
- [container & Image volume](#container--image-volume)
- [/ disk](#-disk)
- [ephemeral storage](#ephemeral-storage)
  - [Size](#size)
  - [emptyDir](#emptydir)
  - [secret](#secret)
  - [configMap](#configmap)
  - [downwardAPI as volume](#downwardapi-as-volume)
- [volumes](#volumes)
- [Types of volumes](#types-of-volumes)
  - [persistentVolumeClaim](#persistentvolumeclaim)
  - [PersistentVolume](#persistentvolume)
  - [k8s storage class](#k8s-storage-class)
- [how to find pod volumes](#how-to-find-pod-volumes)
  - [glusterfs](#glusterfs)
  - [local-storage](#local-storage)
- [epheramal local storage limitatioin](#epheramal-local-storage-limitatioin)
- [Lifecycle of volumes and claims](#lifecycle-of-volumes-and-claims)
  - [Provisioning](#provisioning)
    - [static](#static)
    - [dynamic](#dynamic)
  - [persistentVolumeClaimRetentionPolicy (StatefulSetPersistentVolumeClaimRetentionPolicy)](#persistentvolumeclaimretentionpolicy-statefulsetpersistentvolumeclaimretentionpolicy)



Ephemeral local storage is always made available in the primary partition. There are two basic ways of creating the primary partition: root and runtime.

* Root

This partition holds the kubelet root directory, /var/lib/kubelet/ by default, and /var/log/ directory. This partition can be shared between user pods, the OS, and Kubernetes system daemons. This partition can be consumed by pods through EmptyDir volumes, container logs, image layers, and container-writable layers. Kubelet manages shared access and isolation of this partition. This partition is ephemeral, and applications cannot expect any performance SLAs, such as disk IOPS, from this partition.

How to change kubelet root-dir
```bash
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf

Environment="KUBELET_EXTRA_ARGS=$KUBELET_EXTRA_ARGS --root-dir=/data/k8s/kubelet"

--root-dir string     Default: /var/lib/kubelet
	Directory path for managing kubelet files (volume mounts, etc).
```

* Runtime

This is an optional partition that runtimes can use for overlay file systems. OpenShift Container Platform attempts to identify and provide shared access along with isolation to this partition. Container image layers and writable layers are stored here. If the runtime partition exists, the root partition does not hold any image layer or other writable storage.

# tmpfs
When creating tmpfs without size specified, the size of tmpfs will be half of the size of total memory

here: 189G = 377 * 1/2

```bash
[root@hpg10ncs-hpg10ncs-workerbm-1 tmp]# df -h /dev/shm
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           189G  4.0K  189G   1% /dev/shm
[root@hpg10ncs-hpg10ncs-workerbm-1 tmp]# free -g
              total        used        free      shared  buff/cache   available
Mem:            377          86         205           3          84         273
Swap:             0           0           0
[root@hpg10ncs-hpg10ncs-workerbm-1 tmp]# 

```
Types of tmpfs in kubernetes
* emptyDir w/ memory media
* secret 
* shm
* /sys/fs/cgroup
* /run
* /dev

# container & Image volume
```bash
dev/mapper/vg_root-_data0 on /data0 type xfs (rw,relatime,attr2,inode64,noquota)
```
--data-root=/data0/docker
```bash
[root@hpg10ncs-hpg10ncs-masterbm-0 containers]# cat /etc/sysconfig/docker
OPTIONS='--selinux-enabled=true --storage-driver=overlay2 --storage-opt overlay2.override_kernel_check=true --data-root=/data0/docker --live-restore --mtu=1500 --userland-proxy=false'
[root@hpg10ncs-hpg10ncs-masterbm-0 containers]# 
```

# / disk
```bash
fdisk -l
...
5    335550464   1875384973  734.3G  Microsoft basic primary

[root@hpg10ncs-hpg10ncs-masterbm-0 containers]# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda5       735G  326G  409G  45% /

```

# ephemeral storage
## Size
```bash
[root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# df -h /var/lib/
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda5       735G   46G  689G   7% /

[root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda5       735G   46G  689G   7% /

```
ephemeral disk is normally located in root dir /

Types of ephemeral volumes
* emptyDir w/o memory media
* configMap
* downwardAPI
* CSI emphemeral volume provided by CSI driver
* Generaic ephemeral volumes

emptyDir, configMap, downwardAPI are provided as local ephemeral storage. They are managed by kubelet on each node.

CSI ephemeral volumes: similar to the previous volume kinds, but provided by special CSI drivers which specifically support this feature

Generic ephemeral volumes, which can be provided by all storage drivers that also support persistent volumes

## emptyDir
empty at Pod startup, with storage coming locally from the kubelet base directory (usually the root disk) or RAM

```golang
enum StorageMedium {
  // Magnetic spinning disk.
  STORAGE_MEDIUM_MAGNETIC = 0;
  // SSD disk
  STORAGE_MEDIUM_SSD = 1;
  // NVME disk
  STORAGE_MEDIUM_NVME = 2;
}

// StorageMedium defines ways that storage can be allocated to a volume.
type StorageMedium string

const (
        StorageMediumDefault         StorageMedium = ""           // use whatever the default is for the node, assume anything we don't explicitly handle is this
        StorageMediumMemory          StorageMedium = "Memory"     // use memory (e.g. tmpfs on linux)
        StorageMediumHugePages       StorageMedium = "HugePages"  // use hugepages
        StorageMediumHugePagesPrefix StorageMedium = "HugePages-" // prefix for full medium notation HugePages-<size>
)

```

Current kubernetes only support default and memory and does not support hugepage

* medium == v1.StorageMediumMemory
* medium == v1.StorageMediumDefault

```golang
        case ed.medium == v1.StorageMediumDefault:
                err = ed.setupDir(dir)
        case ed.medium == v1.StorageMediumMemory:
                err = ed.setupTmpfs(dir)
        case v1helper.IsHugePageMedium(ed.medium):
                err = ed.setupHugepages(dir)
```

```golang
func (ed *emptyDir) setupTmpfs(dir string) error {
        if ed.mounter == nil {
                return fmt.Errorf("memory storage requested, but mounter is nil")
        }
        if err := ed.setupDir(dir); err != nil {
                return err
        }
        // Make SetUp idempotent.
        medium, isMnt, _, err := ed.mountDetector.GetMountMedium(dir, ed.medium)
        if err != nil {
                return err
        }
        // If the directory is a mountpoint with medium memory, there is no
        // work to do since we are already in the desired state.
        if isMnt && medium == v1.StorageMediumMemory {
                return nil
        }

        var options []string
        // Linux system default is 50% of capacity.
        if ed.sizeLimit != nil && ed.sizeLimit.Value() > 0 {
                options = []string{fmt.Sprintf("size=%d", ed.sizeLimit.Value())}
        }

        klog.V(3).Infof("pod %v: mounting tmpfs for volume %v", ed.pod.UID, ed.volName)
        return ed.mounter.MountSensitiveWithoutSystemd("tmpfs", dir, "tmpfs", options, nil)
}

func (ed *emptyDir) GetPath() string {
        return getPath(ed.pod.UID, ed.volName, ed.plugin.host)
}
func (kl *Kubelet) getPodVolumeDir(podUID types.UID, pluginName string, volumeName string) string {
        return filepath.Join(kl.getPodVolumesDir(podUID), pluginName, volumeName)
}

const defaultRootDir = "/var/lib/kubelet"

fs.StringVar(&f.RootDirectory, "root-dir", f.RootDirectory, "Directory path for managing kubelet files (volume mounts,etc).")


const (
        DefaultKubeletPodsDirName                = "pods"
        DefaultKubeletVolumesDirName             = "volumes"
        DefaultKubeletVolumeSubpathsDirName      = "volume-subpaths"
        DefaultKubeletVolumeDevicesDirName       = "volumeDevices"
        DefaultKubeletPluginsDirName             = "plugins"
        DefaultKubeletPluginsRegistrationDirName = "plugins_registry"
        DefaultKubeletContainersDirName          = "containers"
        DefaultKubeletPluginContainersDirName    = "plugin-containers"
        DefaultKubeletPodResourcesDirName        = "pod-resources"
        KubeletPluginsDirSELinuxLabel            = "system_u:object_r:container_file_t:s0"
)

```
w/ medium as "memory", kubelet mount memory as volume used by pod
  ```bash
  [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# free -g
              total        used        free      shared  buff/cache   available
    Mem:            377          88         202           4          86         271
    Swap:             0           0           0
    [root@hpg10ncs-hpg10ncs-workerbm-1 kubernetes.io~empty-dir]# df -h | grep cache
    tmpfs                                                                                         189G     0  189G   0% /var/lib/kubelet/pods/09494a7a-c02e-4398-8329-395f85452915/volumes/kubernetes.io~empty-dir/cache-volume-mem

    bash-4.4$ dd if=/dev/zero of=./tst.out bs=1000k count=20000
    20000+0 records in
    20000+0 records out
    20480000000 bytes (20 GB, 19 GiB) copied, 7.7435 s, 2.6 GB/s
    bash-4.4$ 

  [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# df -h | grep cache
    tmpfs                                                                                         189G   20G  170G  11% /var/lib/kubelet/pods/09494a7a-c02e-4398-8329-395f85452915/volumes/kubernetes.io~empty-dir/cache-volume-mem
    [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# free -g
                total        used        free      shared  buff/cache   available
    Mem:            377          89         182          23         105         251
    Swap:             0           0           0
    [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# 

  ```

w/o medium as memory, but it will use ephemeral disk instead of memory
  ```bash
  /var/lib/kubelet/<pid>/volumes/kubernetes.io~empty-dir

  [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# df -h /var/lib/kubelet/pods/09494a7a-c02e-4398-8329-395f85452915/volumes/kubernetes.io~empty-dir/cache-volume
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda5       735G   46G  689G   7% /

    bash-4.4$ dd if=/dev/zero of=./tst.out bs=1000k count=20000
    20000+0 records in
    20000+0 records out
    20480000000 bytes (20 GB, 19 GiB) copied, 8.13844 s, 2.5 GB/s

     

    [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# df -h /var/lib/kubelet/pods/09494a7a-c02e-4398-8329-395f85452915/volumes/kubernetes.io~empty-dir/cache-volume
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda5       735G   65G  670G   9% /
  ```
 

## secret
secret volumes are backed by **tmpfs** (a RAM-backed filesystem)

## configMap
## downwardAPI as volume
https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/#the-downward-api
```
Capabilities of the Downward API

The following information is available to containers through environment variables and downwardAPI volumes:

    Information available via fieldRef:
        metadata.name - the pod's name
        metadata.namespace - the pod's namespace
        metadata.uid - the pod's UID
        metadata.labels['<KEY>'] - the value of the pod's label <KEY> (for example, metadata.labels['mylabel'])
        metadata.annotations['<KEY>'] - the value of the pod's annotation <KEY> (for example, metadata.annotations['myannotation'])
    Information available via resourceFieldRef:
        A Container's CPU limit
        A Container's CPU request
        A Container's memory limit
        A Container's memory request
        A Container's hugepages limit (providing that the DownwardAPIHugePages feature gate is enabled)
        A Container's hugepages request (providing that the DownwardAPIHugePages feature gate is enabled)
        A Container's ephemeral-storage limit
        A Container's ephemeral-storage request

In addition, the following information is available through downwardAPI volume fieldRef:

    metadata.labels - all of the pod's labels, formatted as label-key="escaped-label-value" with one label per line
    metadata.annotations - all of the pod's annotations, formatted as annotation-key="escaped-annotation-value" with one annotation per line

The following information is available through environment variables:

    status.podIP - the pod's IP address
    spec.serviceAccountName - the pod's service account name, available since v1.4.0-alpha.3
    spec.nodeName - the node's name, available since v1.4.0-alpha.3
    status.hostIP - the node's IP, available since v1.7.0-alpha.1

```
* Environment variable
  ```yaml
          - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName


        - name: MY_CPU_REQUEST
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: requests.cpu
        - name: MY_CPU_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: limits.cpu
        - name: MY_MEM_REQUEST
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: requests.memory
        - name: MY_MEM_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: limits.memory
  ```
* Volume Files
  ```yaml
    volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: "labels"
            fieldRef:
              fieldPath: metadata.labels
          - path: "annotations"
            fieldRef:
              fieldPath: metadata.annotations
  ```
  ```yaml
      - name: containerinfo
      downwardAPI:
        items:
          - path: "cpu_limit"
            resourceFieldRef:
              containerName: client-container
              resource: limits.cpu
              divisor: 1m
          - path: "cpu_request"
            resourceFieldRef:
              containerName: client-container
              resource: requests.cpu
              divisor: 1m
          - path: "mem_limit"
            resourceFieldRef:
              containerName: client-container
              resource: limits.memory
              divisor: 1Mi
          - path: "mem_request"
            resourceFieldRef:
              containerName: client-container
              resource: requests.memory
              divisor: 1Mi

  ```

# volumes

On-disk files in a container are ephemeral, which presents some problems for non-trivial applications when running in containers:
* One problem is the loss of files when a container crashes. The kubelet restarts the container but with a clean state. 
* A second problem occurs when sharing files between containers running together in a Pod. 
 
The Kubernetes volume abstraction solves both of these problems

# Types of volumes
* cephfs
* cinder
* configMap
* downwardAPI
* emptyDir
* fc(fibre channel)
* glusterfs
* hostPath
* local
* nfs
* persistentVolumeClaim
* projected
* rbd(Rados Block Device)
* secret
* csi

## persistentVolumeClaim 
A persistentVolumeClaim volume is used to mount a PersistentVolume into a Pod. persistentVolumeClaims are a way for users to "claim" durable storage (such as a GCE PersistentDisk or an iSCSI volume) without knowing the details of the particular cloud environment.

## PersistentVolume 
a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.
* cephfs
* csi
* fc
* glusterfs
* hostPath
* nfs
* rbd
  

## k8s storage class
```bash
[root@hpg10ncs-hpg10ncs-masterbm-0 ryliu (Active)]# kubectl get storageclass
NAME                    PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
csi-cephfs              cephfs.csi.ceph.com            Delete          Immediate              true                   52d
csi-cephrbd (default)   rbd.csi.ceph.com               Delete          Immediate              true                   52d
local-storage           kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  52d
[root@udm012-control-02 ~]# kubectl get storageclass
NAME                           PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
cinder-az-nova (default)       cinder.csi.openstack.org       Delete          Immediate              true                   14d
cinder-az-nova-xfs             cinder.csi.openstack.org       Delete          Immediate              true                   14d
cinder-tripleo-ceph-nova       cinder.csi.openstack.org       Delete          Immediate              true                   14d
cinder-tripleo-ceph-nova-xfs   cinder.csi.openstack.org       Delete          Immediate              true                   14d
cinder-tripleo-nova            cinder.csi.openstack.org       Delete          Immediate              true                   14d
cinder-tripleo-nova-xfs        cinder.csi.openstack.org       Delete          Immediate              true                   14d
glusterfs-storageclass         kubernetes.io/glusterfs        Delete          Immediate              true                   14d
local-storage                  kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  14d
[root@udm012-control-02 ~]# 
```

```yaml
[root@hpg10ncs-hpg10ncs-masterbm-0 ryliu (Active)]# kubectl get storageclass csi-cephrbd -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    meta.helm.sh/release-name: csi-cephrbd
    meta.helm.sh/release-namespace: ncms
    storageclass.kubernetes.io/is-default-class: "true"
  labels:
    app.kubernetes.io/managed-by: Helm
  name: csi-cephrbd
  uid: e6edb2d9-3479-42f5-bab7-1c4ec01f395f
mountOptions:
- discard
parameters:
  clusterID: 95bd2b65-def9-4874-b69c-a4c5971e9e5c
  csi.storage.k8s.io/controller-expand-secret-name: csi-cephrbd
  csi.storage.k8s.io/controller-expand-secret-namespace: ncms
  csi.storage.k8s.io/fstype: ext4
  csi.storage.k8s.io/node-stage-secret-name: csi-cephrbd
  csi.storage.k8s.io/node-stage-secret-namespace: ncms
  csi.storage.k8s.io/provisioner-secret-name: csi-cephrbd
  csi.storage.k8s.io/provisioner-secret-namespace: ncms
  imageFeatures: layering
  imageFormat: "2"
  mounter: kernel
  pool: volumes
allowVolumeExpansion: true
provisioner: rbd.csi.ceph.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    meta.helm.sh/release-name: csi-cephfs
    meta.helm.sh/release-namespace: ncms
  labels:
    app.kubernetes.io/managed-by: Helm
  name: csi-cephfs
  uid: 5a80c8bb-5333-4fd6-819e-caa9eaa6a9e7
parameters:
  clusterID: 95bd2b65-def9-4874-b69c-a4c5971e9e5c
  csi.storage.k8s.io/controller-expand-secret-name: csi-cephfs
  csi.storage.k8s.io/controller-expand-secret-namespace: ncms
  csi.storage.k8s.io/node-stage-secret-name: csi-cephfs
  csi.storage.k8s.io/node-stage-secret-namespace: ncms
  csi.storage.k8s.io/provisioner-secret-name: csi-cephfs
  csi.storage.k8s.io/provisioner-secret-namespace: ncms
  fsName: cephfs
  mounter: kernel
  pool: cephfs_data
  provisionVolume: "true"
allowVolumeExpansion: true
provisioner: cephfs.csi.ceph.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

# how to find pod volumes
```bash
kubectl get pod -n nokia-imshssa qdlab2-rockylinux-sctp-6d94d7f7bf-2tlhw -o jsonpath="{ .metadata.uid }"
/var/lib/kubelet/pods/<pid>

```

## glusterfs
* Find where is your brick
  ```bash
  [root@udm012-control-02 ~]# gluster
  Welcome to gluster prompt, type 'help' to see the available commands.
  gluster> peer status
  Number of Peers: 2

  Hostname: udm012-control-01.storage.bcmt
  Uuid: 425520cd-1872-4992-b2fa-b390c177ecc7
  State: Peer in Cluster (Connected)

  Hostname: 192.168.155.22
  Uuid: 6c5e4c97-1005-4cfe-8e5d-04294d88a0b5
  State: Peer in Cluster (Connected)
  gluster> 
  ```
* 

## local-storage
```yaml
[root@udm012-control-01 ~]# kubectl get storageclass local-storage -o yaml 
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```
Local volumes do not currently support dynamic provisioning, however a StorageClass should still be created to delay volume binding until Pod scheduling. This is specified by the WaitForFirstConsumer volume binding mode.

Delaying volume binding allows the scheduler to consider all of a Pod's scheduling constraints when choosing an appropriate PersistentVolume for a PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  finalizers:
  - kubernetes.io/pv-protection
  labels:
    app: bcmt-cmdb
    type: local
  name: cmdb-mysql-udm012-control-02
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: datadir-bcmt-cmdb-mariadb-0
    namespace: ncms
    resourceVersion: "6444"
    uid: de1927af-0c46-409b-ac08-015e5a4efcc2
  local:
    path: /data0/cmdb-mysql
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - udm012-control-02
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  volumeMode: Filesystem
```

# epheramal local storage limitatioin

```golang
// localStorageEviction checks the EmptyDir volume usage for each pod and determine whether it exceeds the specified limit and needs
// to be evicted. It also checks every container in the pod, if the container overlay usage exceeds the limit, the pod will be evicted too.
func (m *managerImpl) localStorageEviction(pods []*v1.Pod, statsFunc statsFunc) []*v1.Pod {
        evicted := []*v1.Pod{}
        for _, pod := range pods {
                podStats, ok := statsFunc(pod)
                if !ok {
                        continue
                }

                if m.emptyDirLimitEviction(podStats, pod) {
                        evicted = append(evicted, pod)
                        continue
                }

                if m.podEphemeralStorageLimitEviction(podStats, pod) {
                        evicted = append(evicted, pod)
                        continue
                }

                if m.containerEphemeralStorageLimitEviction(podStats, pod) {
                        evicted = append(evicted, pod)
                }
        }

        return evicted
}

func (m *managerImpl) emptyDirLimitEviction(podStats statsapi.PodStats, pod *v1.Pod) bool {
        podVolumeUsed := make(map[string]*resource.Quantity)
        for _, volume := range podStats.VolumeStats {
                podVolumeUsed[volume.Name] = resource.NewQuantity(int64(*volume.UsedBytes), resource.BinarySI)
        }
        for i := range pod.Spec.Volumes {
                source := &pod.Spec.Volumes[i].VolumeSource
                if source.EmptyDir != nil {
                        size := source.EmptyDir.SizeLimit
                        used := podVolumeUsed[pod.Spec.Volumes[i].Name]
                        if used != nil && size != nil && size.Sign() == 1 && used.Cmp(*size) > 0 {
                                // the emptyDir usage exceeds the size limit, evict the pod
                                if m.evictPod(pod, 0, fmt.Sprintf(emptyDirMessageFmt, pod.Spec.Volumes[i].Name, size.String()), nil) {
                                        metrics.Evictions.WithLabelValues(signalEmptyDirFsLimit).Inc()
                                        return true
                                }
                                return false
                        }
                }
        }

        return false
}

// Different container runtimes.
const (
        DockerContainerRuntime = "docker"
        RemoteContainerRuntime = "remote"
)

const (
        // CrioSocket is the path to the CRI-O socket.
        // Please keep this in sync with the one in:
        // github.com/google/cadvisor/tree/master/container/crio/client.go
        CrioSocket = "/var/run/crio/crio.sock"
)


root       27027       1 19 Jun16 ?        1-04:40:34 /usr/local/bin/kubelet --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --config=/etc/kubernetes/kubelet-config.yml --register-node=true --hostname-override=hpg10ncs-hpg10ncs-masterbm-0 --node-labels=is_control=true,is_worker=false,is_edge=false,is_storage=false,bcmt_storage_node=true,rook_storage=false,rook_storage2=false,cpu_pooler_active=false,dynamic_local_storage_node=false,local_storage_node=false,topology.kubernetes.io/region=hpg10ncs-hpg10ncs,topology.kubernetes.io/zone=zone1 --register-with-taints=is_control=true:NoExecute --node-ip=172.31.7.2 --cloud-provider= --hostname-override=hpg10ncs-hpg10ncs-masterbm-0 --pod-max-pids=4096 --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --v=1

// UsingLegacyCadvisorStats returns true if container stats are provided by cadvisor instead of through the CRI.
// CRI integrations should get container metrics via CRI. Docker
// uses the built-in cadvisor to gather such metrics on Linux for
// historical reasons.
// TODO: cri-o relies on cadvisor as a temporary workaround. The code should
// be removed. Related issue:
// https://github.com/kubernetes/kubernetes/issues/51798
func UsingLegacyCadvisorStats(runtime, runtimeEndpoint string) bool {
        return (runtime == kubetypes.DockerContainerRuntime && goruntime.GOOS == "linux") ||
                runtimeEndpoint == CrioSocket || runtimeEndpoint == "unix://"+CrioSocket
}

        if kubeDeps.useLegacyCadvisorStats {
                klet.StatsProvider = stats.NewCadvisorStatsProvider(
                        klet.cadvisor,
                        klet.resourceAnalyzer,
                        klet.podManager,
                        klet.runtimeCache,
                        klet.containerRuntime,
                        klet.statusManager,
                        hostStatsProvider)
        } else {
                klet.StatsProvider = stats.NewCRIStatsProvider(
                        klet.cadvisor,
                        klet.resourceAnalyzer,
                        klet.podManager,
                        klet.runtimeCache,
                        kubeDeps.RemoteRuntimeService,
                        kubeDeps.RemoteImageService,
                        hostStatsProvider,
                        utilfeature.DefaultFeatureGate.Enabled(features.DisableAcceleratorUsageMetrics),
                        utilfeature.DefaultFeatureGate.Enabled(features.PodAndContainerStatsFromCRI))

 podStats.EphemeralStorage = calcEphemeralStorage(podStats.Containers, ephemeralStats, &rootFsInfo, logStats, etcHostsStats, false)
 s.EphemeralStorage = calcEphemeralStorage(s.Containers, ephemeralStats, rootFsInfo, logStats, etcHostsStats, true)

        if stats.WritableLayer != nil {
                result.Rootfs.Time = metav1.NewTime(time.Unix(0, stats.WritableLayer.Timestamp))
                if stats.WritableLayer.UsedBytes != nil {
                        result.Rootfs.UsedBytes = &stats.WritableLayer.UsedBytes.Value
                }
                if stats.WritableLayer.InodesUsed != nil {
                        result.Rootfs.InodesUsed = &stats.WritableLayer.InodesUsed.Value
                }
        }

func addContainerUsage(stat *statsapi.FsStats, container *statsapi.ContainerStats, isCRIStatsProvider bool) {
        if rootFs := container.Rootfs; rootFs != nil {
                stat.Time = maxUpdateTime(&stat.Time, &rootFs.Time)
                stat.InodesUsed = addUsage(stat.InodesUsed, rootFs.InodesUsed)
                stat.UsedBytes = addUsage(stat.UsedBytes, rootFs.UsedBytes)
                if logs := container.Logs; logs != nil {
                        stat.UsedBytes = addUsage(stat.UsedBytes, logs.UsedBytes)
                        // We have accurate container log inode usage for CRI stats provider.
                        if isCRIStatsProvider {
                                stat.InodesUsed = addUsage(stat.InodesUsed, logs.InodesUsed)
                        }
                        stat.Time = maxUpdateTime(&stat.Time, &logs.Time)
                }
        }
}


func calcEphemeralStorage(containers []statsapi.ContainerStats, volumes []statsapi.VolumeStats, rootFsInfo *cadvisorapiv2.FsInfo,
        podLogStats *statsapi.FsStats, etcHostsStats *statsapi.FsStats, isCRIStatsProvider bool) *statsapi.FsStats {
        result := &statsapi.FsStats{
                Time:           metav1.NewTime(rootFsInfo.Timestamp),
                AvailableBytes: &rootFsInfo.Available,
                CapacityBytes:  &rootFsInfo.Capacity,
                InodesFree:     rootFsInfo.InodesFree,
                Inodes:         rootFsInfo.Inodes,
        }
        for _, container := range containers {
                addContainerUsage(result, &container, isCRIStatsProvider)
        }
        for _, volume := range volumes {
                result.UsedBytes = addUsage(result.UsedBytes, volume.FsStats.UsedBytes)
                result.InodesUsed = addUsage(result.InodesUsed, volume.InodesUsed)
                result.Time = maxUpdateTime(&result.Time, &volume.FsStats.Time)
        }
        if podLogStats != nil {
                result.UsedBytes = addUsage(result.UsedBytes, podLogStats.UsedBytes)
                result.InodesUsed = addUsage(result.InodesUsed, podLogStats.InodesUsed)
                result.Time = maxUpdateTime(&result.Time, &podLogStats.Time)
        }
        if etcHostsStats != nil {
                result.UsedBytes = addUsage(result.UsedBytes, etcHostsStats.UsedBytes)
                result.InodesUsed = addUsage(result.InodesUsed, etcHostsStats.InodesUsed)
                result.Time = maxUpdateTime(&result.Time, &etcHostsStats.Time)
        }
        return result
}

func (m *managerImpl) podEphemeralStorageLimitEviction(podStats statsapi.PodStats, pod *v1.Pod) bool {
        _, podLimits := apiv1resource.PodRequestsAndLimits(pod)
        _, found := podLimits[v1.ResourceEphemeralStorage]
        if !found {
                return false
        }

        // pod stats api summarizes ephemeral storage usage (container, emptyDir, host[etc-hosts, logs])
        podEphemeralStorageTotalUsage := &resource.Quantity{}
        if podStats.EphemeralStorage != nil && podStats.EphemeralStorage.UsedBytes != nil {
                podEphemeralStorageTotalUsage = resource.NewQuantity(int64(*podStats.EphemeralStorage.UsedBytes), resource.BinarySI)
        }
        podEphemeralStorageLimit := podLimits[v1.ResourceEphemeralStorage]
        if podEphemeralStorageTotalUsage.Cmp(podEphemeralStorageLimit) > 0 {
                // the total usage of pod exceeds the total size limit of containers, evict the pod
                if m.evictPod(pod, 0, fmt.Sprintf(podEphemeralStorageMessageFmt, podEphemeralStorageLimit.String()), nil) {
                        metrics.Evictions.WithLabelValues(signalEphemeralPodFsLimit).Inc()
                        return true
                }
                return false
        }
        return false
}

func (m *managerImpl) containerEphemeralStorageLimitEviction(podStats statsapi.PodStats, pod *v1.Pod) bool {
        thresholdsMap := make(map[string]*resource.Quantity)
        for _, container := range pod.Spec.Containers {
                ephemeralLimit := container.Resources.Limits.StorageEphemeral()
                if ephemeralLimit != nil && ephemeralLimit.Value() != 0 {
                        thresholdsMap[container.Name] = ephemeralLimit
                }
        }

        for _, containerStat := range podStats.Containers {
                containerUsed := diskUsage(containerStat.Logs)
                if !*m.dedicatedImageFs {
                        containerUsed.Add(*diskUsage(containerStat.Rootfs))
                }

                if ephemeralStorageThreshold, ok := thresholdsMap[containerStat.Name]; ok {
                        if ephemeralStorageThreshold.Cmp(*containerUsed) < 0 {
                                if m.evictPod(pod, 0, fmt.Sprintf(containerEphemeralStorageMessageFmt, containerStat.Name, ephemeralStorageThreshold.String()), nil) {
                                        metrics.Evictions.WithLabelValues(signalEphemeralContainerFsLimit).Inc()
                                        return true
                                }
                                return false
                        }
                }
        }
        return false
}

```

Test on hsscallp (6 containers)

```yaml
    resources:
      limits:
        cpu: 200m
        ephemeral-storage: 1G
        memory: 2000Mi
      requests:
        cpu: 200m
        ephemeral-storage: "0"
        memory: 2000Mi
```
```bash
cd /logstores
dd if=/dev/zero of=./test.out bs=1000 count=10000000
```
pod evicted
```
Warning  Evicted              58s                 kubelet  Pod ephemeral local storage usage exceeds the total limit of containers 6G.
```
Above 6G = 6 * 1G.
Based on above code, podEphermeralStorgeLimitEviction will be checked firstly so above logs printed


# Lifecycle of volumes and claims
## Provisioning
### static
A cluster administrator creates a number of PVs. They carry the details of the real storage, which is available for use by cluster users
### dynamic
When none of the static PVs the administrator created match a user's PersistentVolumeClaim, the cluster may try to dynamically provision a volume specially for the PVC

## persistentVolumeClaimRetentionPolicy (StatefulSetPersistentVolumeClaimRetentionPolicy)

persistentVolumeClaimRetentionPolicy describes the lifecycle of persistent volume claims created from volumeClaimTemplates. **By default, all persistent volume claims are created as needed and retained until manually deleted.** This policy allows the lifecycle to be altered, for example by deleting persistent volume claims when their stateful set is deleted, or when their pod is scaled down. This requires the StatefulSetAutoDeletePVC feature gate to be enabled, which is alpha. +optional

StatefulSetPersistentVolumeClaimRetentionPolicy describes the policy used for PVCs created from the StatefulSet VolumeClaimTemplates.

    persistentVolumeClaimRetentionPolicy.whenDeleted (string)

    WhenDeleted specifies what happens to PVCs created from StatefulSet VolumeClaimTemplates when the StatefulSet is deleted. The default policy of Retain causes PVCs to not be affected by StatefulSet deletion. The Delete policy causes those PVCs to be deleted.

    persistentVolumeClaimRetentionPolicy.whenScaled (string)

    WhenScaled specifies what happens to PVCs created from StatefulSet VolumeClaimTemplates when the StatefulSet is scaled down. The default policy of Retain causes PVCs to not be affected by a scaledown. The Delete policy causes the associated PVCs for any excess pods above the replica count to be deleted.
