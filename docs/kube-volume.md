This page is related with volumes
---

# volumes used in NCS
```bash
kubernetes.io~configmap
kubernetes.io~csi
kubernetes.io~empty-dir
kubernetes.io~secret
```
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

emptyDir, configMap, downwardAPI, secret are provided as local ephemeral storage. They are managed by kubelet on each node.

CSI ephemeral volumes: similar to the previous volume kinds, but provided by special CSI drivers which specifically support this feature

Generic ephemeral volumes, which can be provided by all storage drivers that also support persistent volumes

## emptyDir: empty at Pod startup, with storage coming locally from the kubelet base directory (usually the root disk) or RAM

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
## downwardAPI
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
## CSI ephemerial volumes
the storage is managed locally on each node and is created together with other local resources after a Pod has been scheduled onto a node

A csi volume can be used in a Pod in three different ways:

    * through a reference to a PersistentVolumeClaim
    * with a generic ephemeral volume (alpha feature)
    * with a CSI ephemeral volume if the driver supports that (beta feature)


## cephfs
  
  A cephfs volume allows an existing CephFS volume to be mounted into your Pod;

  the contents of a cephfs volume are preserved and the volume is merely unmounted

  This means that a cephfs volume can be pre-populated with data, and that data can be shared between pods

  NOTE: You must have your own Ceph server running with the share exported before you can use it

* cinder
  
## General ephemeral volumes

# persistent storage 

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

# how to find pod volumes
```bash
kubectl get pod -n nokia-imshssa qdlab2-rockylinux-sctp-6d94d7f7bf-2tlhw -o jsonpath="{ .metadata.uid }"
/var/lib/kubelet/pods/<pid>

```

