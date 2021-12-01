This page is related with volumes
---

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

## Types of ephemeral volumes

Kubernetes supports several different kinds of ephemeral volumes for different purposes:

### emptyDir: empty at Pod startup, with storage coming locally from the kubelet base directory (usually the root disk) or RAM

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

w/o medium as memory, but it still is using "memory" 
  ```bash
     /var/lib/kubelet/<pid>/volumes/kubernetes.io~empty-dir
     [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# free -g
              total        used        free      shared  buff/cache   available
    Mem:            377          87         203           4          86         272
    Swap:             0           0           0

    bash-4.4$ dd if=/dev/zero of=./tst.out bs=1000k count=20000
    20000+0 records in
    20000+0 records out
    20480000000 bytes (20 GB, 19 GiB) copied, 8.13844 s, 2.5 GB/s

    [root@hpg10ncs-hpg10ncs-workerbm-1 cache-volume]# free -g
                total        used        free      shared  buff/cache   available
    Mem:            377          88         183           4         105         271
    Swap:             0           0           0
  ```
 
### configMap, downwardAPI, secret: inject different kinds of Kubernetes data into a Pod
### CSI ephemeral volumes: similar to the previous volume kinds, but provided by special CSI drivers which specifically support this feature
### generic ephemeral volumes, which can be provided by all storage drivers that also support persistent volumes

**emptyDir, configMap, downwardAPI, secret** are provided as local ephemeral storage. They are managed by kubelet on each node.

CSI ephemeral volumes must be provided by third-party CSI storage drivers.

Generic ephemeral volumes can be provided by third-party CSI storage drivers, but also by any other storage driver that supports dynamic provisioning. Some CSI drivers are written specifically for CSI ephemeral volumes and do not support dynamic provisioning: those then cannot be used for generic ephemeral volumes.

# persistent storage 

# how to find pod volumes
```bash
kubectl get pod -n nokia-imshssa qdlab2-rockylinux-sctp-6d94d7f7bf-2tlhw -o jsonpath="{ .metadata.uid }"
/var/lib/kubelet/pods/<pid>

```

