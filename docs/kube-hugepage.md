HugePage related information
------------------

- [What is HugePage and its features?](#what-is-hugepage-and-its-features)
- [Why Linux introduces Hugepage](#why-linux-introduces-hugepage)
- [How to use hugepage](#how-to-use-hugepage)
  - [Hugepagetls](#hugepagetls)
  - [VMA on THP](#vma-on-thp)
  - [Hugepage Interfaces](#hugepage-interfaces)
  - [Support variable-sized hugepage](#support-variable-sized-hugepage)
  - [madvise](#madvise)
- [Hugepage Use Cases](#hugepage-use-cases)
- [How to know pagesize](#how-to-know-pagesize)
- [meminfo](#meminfo)
- [How to configure Hugepage](#how-to-configure-hugepage)
  - [Parameter used to configure HugeTLB at boot time](#parameter-used-to-configure-hugetlb-at-boot-time)
  - [Parameters used to configure HugeTLB at run time](#parameters-used-to-configure-hugetlb-at-run-time)
- [How to configure THP](#how-to-configure-thp)
- [Hugepage Usage Examples](#hugepage-usage-examples)

https://github.com/libhugetlbfs/libhugetlbfs

/sys/kernel/mm/hugepages/

# What is HugePage and its features?

Hugepages is a feature that allows the Linux kernel to utilize the multiple page size capabilities of modern hardware architectures

A page is the basic unit of virtual memory which is mapped to phyiscal RAM and swap

* Default pagesize: 4096bytes (4k)
* Hugepage size
  * 2048k (2m)
  * 1g
  
  Two Kind of Hugepage:
  * HugeTLB pages (**static** huge pages): Explicit Huge Pages which are allocated explicitly by vm.nr_hugepages sysctl parameter
    * How to enable/disable Explicit Huge Page: vm.nu_hugepages
      * 0: disable
      * > 0: enable
  * Transparent Huge Pages (THP) which are allocated automatically by the kernel, no need to manually reserve the static huge pages
    * system-wide mode
      * the kernel tries to assign huge pages to a process whenever it is possible to allocate the huge pages and the process is using a large contiguous virtual memory area
    * per-process mode
      * the kernel only assigns huge pages to the memory areas of individual processes which you can specify using the madvise() system call.


# Why Linux introduces Hugepage

* Linux uses a mechanism in the CPU architecture called "Translation Lookaside Buffers" (TLB) to manage the mapping of virtual memory pages to actual physical memory addresses. 
* The TLB is a limited hardware resource, so utilizing a huge amount of physical memory with the default page size consumes the TLB and adds processing overhead - many pages of size 4096 Bytes equates to many TLB resources consumed. 
* By utilizing Huge Pages, we are able to create pages of much larger sizes, each page consuming a single resource in the TLB. 

# How to use hugepage
## Hugepagetls
* A side effect of creating Huge Pages is that the physical memory that is mapped to a Huge Page is no longer subject to normal memory allocations or managed by the kernel virtual memory manager, 
* so Huge Pages are essentially 'protected' and are available only to applications that request them. Huge Pages are 'pinned' to physical RAM and cannot be swapped/paged out.
* Users can use the huge page support in Linux kernel by either using the 
  * **mmap system call** or 
  * **standard SYSV shared memory system calls (shmget, shmat)**.
    * shmget with SHM_HUGETLB flag and only works with default hugepagesz (boot time configured showed in meminfo)

* hugetlbfs is the only for user-space to take advantage of hugepages in current kerenel
* But it requires significant work from both application developers and system adminstrators
  * hugepage must be set aside at boot time
  * application must map them explicitly
* THP is used to try to make huge pages in situations where they would be useful w/o devlopment or administrative attention
* 
## VMA on THP
Current Linux kernels assume that all pages found within a given virtual memory area (VMA) will be the same size. THP breaks t his assumpation
* the kernel will attempt to allocate a huge page to satisfy it if huge memory allocated. Should the allocation succeed, the huge page will be filled, any existing small pages in the new page's address range will be released, and the huge page will be inserted into the VMA. 
* If no huge pages are available, the kernel falls back to small pages and the application never knows the difference.

This scheme will increase the use of huge pages transparently

The allocation of huge pages depends on the availability of large, physically-contiguous chunks of memory 
* khugepaged: scan through memory looking for a place where that huge page can be substituted for a bunch of smaller pages
* THP only works with anonymous pages and onhly handles on 2MB hugepagesz
* No application changes need to be made to take advantage of THP
* but interested application developers can try to optimize their use of it
  * madvise() w/ MADV_HUGEPAGE flag Enable Transparent Huge Pages (THP) for pages in the range specified by addr and length.
  * madvise() w/o  MADV_NOHUGEPAGE will Ensures that memory in the address range specified by addr and length will not be backed by transparent hugepages.
  * For applications that want to use huge pages, use of posix_memalign() can help to ensure that large allocations are aligned to huge page (2MB) boundaries.

## Hugepage Interfaces 
https://lwn.net/Articles/375096/

1. Shared Memory
   1. shmget with SHM_HUGETLB flag on default_hugepagesz configured in kernel command line parameter
2. HugeTLBFS: RAM-based filesystem called "hugetlbfs"
   1. mount -t hugetlbfs none /mnt/hugetlbfs -o pagesize=64K (if no -o, then default hugepage size will be used)
   2. w/ hugetlbfs, application can use different hugepagesz
   3. every file on this FS is backed by hugepages and access with mmap() or read()
   4. libhugtlsfs is user interfaces to access this FS
3. Anonymous mmap
   1. mmap with MAP_ANONYMOUS|MAP_HUGETLB
4. libhugetlbfs allocation APIS
   1. get_hugepage_region
   2. get_huge_pages
   3. free_hugepage_region
   4. free_huge_pages
5. Automatic Backing of Memory Regions
   1. Shared Memory
      1. override all calls to shmget by libhugetlbfs when preloaded or linked with env variables HUGETLB_SHM
   2. Heap
      1. libhugetlbfs is preloaded or linked and env variables HUGETLB_MORECORE = yes, libhugetlbfs will configure __morecore hok 
      2. malloc request will use hugepages 
   3. Text and Data
   4. Stack

## Support variable-sized hugepage
* Explicitly Hugepages
  * shmget() with SHM_HUGETLB flag
    * SHM_HUGE_2MB
    * SHM_HUGE_1GB
    * shmget(key, size, flags | SHM_HUGETLB | SHM_HUGE_2MB);
  * map() with MAP_HUGETLB
    * MAP_HUGE_2MB
    * MAP_HUGE_1GB
* THP
  * No any changes on application but only applied to default hugepagesz

## madvise
* The madvise() system call is used to give advice or directions to the kernel about the address range beginning at address addr and with size length
* madvise() only operates on whole pages then **addr must be page-aligned.**
* the length is rounded up to a multple of pages size
* advices
  * MADV_NORMAL
  * MADV_RANDOM
  * ...
  * MADV_HUGEPAGE: Enable Transparent Huge Pages (THP) for pages in the range specified by addr and length
  * MADV_NOHUGEPAGE


# Hugepage Use Cases
* A typical purpose for allocating Huge Pages is for an application that has characteristic high memory use, and you wish to ensure that the pages it uses are never swapped out when the system is under memory pressure
* Another purpose is to manage memory usage on a 32bit system - Creating Huge Pages and configuring applications to use them will reduce the kernel's memory management overhead since it will be managing fewer pages. The kernel virtual memory manager utilizes low memory - fewer pages to manage means it will consume less low memory.

# How to know pagesize
```bash
# cat /proc/meminfo |grep Hugepagesize
Hugepagesize: 2048 kB
```
* [ how to chnage default hugepage size in RedHat 8/9 ](https://access.redhat.com/solutions/3936101)
  * kernel boot parameter default_hugepagesz is used to set the size of the default HugeTLB page

# meminfo
```bash
HugePages_Total: uuu
HugePages_Free:  vvv
HugePages_Rsvd:  www
HugePages_Surp:  xxx
Hugepagesize:    yyy kB
Hugetlb:         zzz kB
```
* HugePage_Total: the size of the pool of huge pages
* HugePages_Free: the number of huge pages in the pool that are not yet allocated
* HugePages_Rsvd: the number of huge pages for which a commitment to allocate from the pool has been made, but no allocation has yet been made. Reserved huge pages guarantee that an application will be able to allocate a huge page from the pool of huge pages at fault time
* HugePages_Surp: the number of huge pages in the pool above the value in /proc/sys/vm/nr_hugepages.The maximum number of surplus huge pages is controlled by /proc/sys/vm/nr_overcommit_hugepages
* Hugepagesize: the default hugepage size (in kB).
* Hubetlb: the total amount of memory (in kB), consumed by huge pages of all sizes If huge pages of different sizes are in use, this number will exceed HugePages_Total * Hugepagesize. To get more detailed information, please, refer to /sys/kernel/mm/hugepages (described below).
  * if single pagesize, then Hugetlb = HugepageSize * HugePates_Total
    ```bash
        root@tstbed-1:~# cat /proc/meminfo  | grep -i huge
        AnonHugePages:    442368 kB
        ShmemHugePages:        0 kB
        FileHugePages:         0 kB
        HugePages_Total:      10
        HugePages_Free:       10
        HugePages_Rsvd:        0
        HugePages_Surp:        0
        Hugepagesize:       2048 kB
        Hugetlb:           20480 kB
        root@tstbed-1:~# 
    ```
  * if multiple pagesize (default size is 2MB): Hugetlb (both hugepagesz memory)= Hugepagesize * HugePages_Total + /sys/kernel/mm/hugepages/hugepages-1048576kB * 1024 * 1024
    ```bash
        root@tstbed-1:~# cat /proc/meminfo | grep -i huge
        AnonHugePages:    442368 kB
        ShmemHugePages:        0 kB
        FileHugePages:         0 kB
        HugePages_Total:      10
        HugePages_Free:       10
        HugePages_Rsvd:        0
        HugePages_Surp:        0
        Hugepagesize:       2048 kB
        Hugetlb:         4214784 kB
    ```

# How to configure Hugepage
## Parameter used to configure HugeTLB at boot time
* hugepages: vm.nr_hugepages; default 0
* hugepagesz: 2MB or 1GB; default 2MB
* default_hugepagesz: 2MB or 1GB; default 2MB
## Parameters used to configure HugeTLB at run time
* nr_hugepages: /sys/devices/system/node/<node_id>/hugepages/hugepages-size/nr_hugepages
* nr_overcommit_hugepages: /proc/sys/vm/nr_overcommit_hugepages
* 

# How to configure THP
* Transparent huge pages are **enabled** by default
* cat /sys/kernel/mm/transparent_hugepage/enabled
  * always: enable THP
  * never: disable TPH
  * madvise: disable the system-wide transparent huge pages and only enable them for the applications that explicitly request it through the madvise
* To disable THP boot time (grub.conf)
  ```
  transparent_hugepage=never
  ```
* To disable THP runtime
  ```bash
    # echo never > /sys/kernel/mm/transparent_hugepage/enabled
    # echo never > /sys/kernel/mm/transparent_hugepage/defrag
  ```
* dd
To check System Usage of THP:

AnonHugePages = nr_anon_transparent_hugepages * 2MB

```bash
root@tstbed-1:/sys/kernel/mm/transparent_hugepage# grep AnonHugePages /proc/meminfo 
AnonHugePages:    442368 kB
root@tstbed-1:/sys/kernel/mm/transparent_hugepage# 
```

```bash
root@tstbed-1:/sys/kernel/mm/transparent_hugepage#  egrep 'trans|thp' /proc/vmstat
nr_anon_transparent_hugepages 216
thp_migration_success 8355
thp_migration_fail 0
thp_migration_split 0
thp_fault_alloc 2167
thp_fault_fallback 0
thp_fault_fallback_charge 0
thp_collapse_alloc 156
thp_collapse_alloc_failed 0
thp_file_alloc 0
thp_file_fallback 0
thp_file_fallback_charge 0
thp_file_mapped 0
thp_split_page 0
thp_split_page_failed 0
thp_deferred_split_page 58
thp_split_pmd 59
thp_split_pud 0
thp_zero_page_alloc 1
thp_zero_page_alloc_failed 0
thp_swpout 0
thp_swpout_fallback 0
root@tstbed-1:/sys/kernel/mm/transparent_hugepage# 
```
To check THP usage per process
```bash
root@tstbed-1:/sys/kernel/mm/transparent_hugepage# awk  '/AnonHugePages/ { if($2>4){print FILENAME " " $0; system("ps -fp " gensub(/.*\/([0-9]+).*/, "\\1", "g", FILENAME))}}' /proc/*/smaps
/proc/307514/smaps AnonHugePages:      2048 kB
UID          PID    PPID  C STIME TTY          TIME CMD
root      307514  307484 13 Aug16 ?        3-14:39:35 kube-apiserver --advertise-address=10.67.26.196 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-to
/proc/307514/smaps AnonHugePages:      2048 kB
UID          PID    PPID  C STIME TTY          TIME CMD
root      307514  307484 13 Aug16 ?        3-14:39:35 kube-apiserver --advertise-address=10.67.26.196 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-to
/proc/307514/smaps AnonHugePages:      2048 kB
UID          PID    PPID  C STIME TTY          TIME CMD
root      307514  307484 13 Aug16 ?        3-14:39:35 kube-apiserver --advertise-address=10.67.26.196 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-to
/proc/307514/smaps AnonHugePages:      2048 kB
```
![THP Usage per system and per process](pics/thp.PNG)

# Hugepage Usage Examples

https://github.com/ryanlyy/kdb/tree/master/src/hugepage

