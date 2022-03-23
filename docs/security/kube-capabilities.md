Linux Capabilities
---
- [PodSecurityPolicy](#podsecuritypolicy)
- [Overview](#overview)
- [File Permission](#file-permission)
  - [setuid and setgid](#setuid-and-setgid)
  - [Permission Bit](#permission-bit)
- [User ID](#user-id)
- [Thread capability sets](#thread-capability-sets)
- [File capabilites sets](#file-capabilites-sets)
- [Capabilities and execution of programs by root](#capabilities-and-execution-of-programs-by-root)
- [Set-user-ID-root programs that have file capabilities](#set-user-id-root-programs-that-have-file-capabilities)
- [How to find the capabilites that running process required](#how-to-find-the-capabilites-that-running-process-required)
- [How to find the capabilities that file execution required](#how-to-find-the-capabilities-that-file-execution-required)
- [How to set capabilities](#how-to-set-capabilities)
- [File Attributes](#file-attributes)
  - [What is chattr and lsattr ?](#what-is-chattr-and-lsattr-)
  - [Why to use chattr and lsattr ?](#why-to-use-chattr-and-lsattr-)
- [File Time](#file-time)
  - [How to find create time](#how-to-find-create-time)
- [Run tcpdump w/ Non-root](#run-tcpdump-w-non-root)
- [Refereces](#refereces)

# PodSecurityPolicy

RequiredDropCapabilities (ALL) will be automatically added to pod container securityContext

# Overview

For the purpose of performing permission checks, traditional UNIX  implementations distinguish two categories of processes:

* privileged processes (whose effective user ID is 0, referred to as superuser or root)
  
  Privileged processes **bypass all kernel permission checks**

* unprivileged processes (whose effective UID is nonzero).  
  
  while unprivileged processes are subject to full permission checking based on the process's credentials (usually: effective UID, effective GID, and supplementary group list)
  
NOTE: Capabilities are a per-thread attribute.

# File Permission 

https://www.cbtnuggets.com/blog/technology/system-admin/linux-file-permissions-understanding-setuid-setgid-and-the-sticky-bit

## setuid and setgid
Setuid and setgid are a way for users to run an executable with the permissions of the user (setuid) or group (setgid) who owns the file. For example, if you want a user to be able to perform a specific task that requires root/superuser privileges, but don't want to give them sudo or root access.

```bash
[root@foss-ssc-6 ~]# mkdir /topsecretfolder
[root@foss-ssc-6 ~]# cd /topsecretfolder/
[root@foss-ssc-6 topsecretfolder]# mkdir secret1
[root@foss-ssc-6 topsecretfolder]# mkdir secret2
[root@foss-ssc-6 topsecretfolder]# ls -l
total 0
drwxr-xr-x. 2 root root 6 Mar 13 15:16 secret1
drwxr-xr-x. 2 root root 6 Mar 13 15:16 secret2
[root@foss-ssc-6 topsecretfolder]# chmod o-rx secret2/
[root@foss-ssc-6 topsecretfolder]# ls -l
total 0
drwxr-xr-x. 2 root root 6 Mar 13 15:16 secret1
drwxr-x---. 2 root root 6 Mar 13 15:16 secret2
[root@foss-ssc-6 topsecretfolder]#

[utest@foss-ssc-6 topsecretfolder]$ ls secret1
[utest@foss-ssc-6 topsecretfolder]$ ls secret2
ls: cannot open directory 'secret2': Permission denied
[utest@foss-ssc-6 topsecretfolder]$
```
Above make sense since user utest can't access secret2 rejected by kernel permission check

another example "passwd", Changing passwd inherently requires changing /etc/shadown which is only root accessable.

```bash
[utest@foss-ssc-6 topsecretfolder]$ ls -l /etc/shadow
----------. 1 root root 2173 Mar 13 14:10 /etc/shadow
[utest@foss-ssc-6 topsecretfolder]$ ls -l /usr/bin/passwd
-rwsr-xr-x. 1 root root 33600 Apr  7  2020 /usr/bin/passwd
[utest@foss-ssc-6 topsecretfolder]$
```

Why passwd can access /etc/shadow, it permission mode has "s" which means setuid bit is set


## Permission Bit

* setuid: a bit that makes an executable run with the privileges of the owner of the file
* setgid: a bit that makes an executable run with the privileges of the group of the file
* sticky bit: a bit set on directories that allows only the owner or root can delete files and subdirectories

How to change setuid/groupid:

```bash
[root@foss-ssc-6 topsecretfolder]# ls -ls /usr/bin/ping
76 -rwxr-xr-x. 1 root root 77216 Nov  9  2019 /usr/bin/ping
[root@foss-ssc-6 topsecretfolder]# chmod u+s /usr/bin/ping
[root@foss-ssc-6 topsecretfolder]# set -o vi
[root@foss-ssc-6 topsecretfolder]# ls -ls /usr/bin/ping
76 -rwsr-xr-x. 1 root root 77216 Nov  9  2019 /usr/bin/ping
[root@foss-ssc-6 topsecretfolder]#
[root@foss-ssc-6 topsecretfolder]# chmod u-s /usr/bin/ping
[root@foss-ssc-6 topsecretfolder]# ls -ls /usr/bin/ping
76 -rwxr-xr-x. 1 root root 77216 Nov  9  2019 /usr/bin/ping
[root@foss-ssc-6 topsecretfolder]#

```

# User ID

* User ID
  ```bash
  [utest@foss-ssc-6 ~]$ id
  uid=1008(utest) gid=1011(utest) groups=1011(utest) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
  [utest@foss-ssc-6 ~]$ 
  ```

* Real User ID
  
  The real UID (ruid) and real GID (rgid) identify the real owner of the process and affect the permissions for sending signals. 
  
  A process without superuser privileges may signal another process only if the sender's ruid or euid matches receiver's ruid or suid. Because a child process inherits its credentials from its parent, a child and parent may signal each other. 

  ```bash
    [utest@foss-ssc-6 ~]$ sleep 100 & ps aux | grep 'sleep'
    [2] 2023432
    utest    2023432  0.0  0.0 217068   900 pts/13   S    14:41   0:00 sleep 100
    utest    2023434  0.0  0.0 221924  1184 pts/13   S+   14:41   0:00 grep --color=auto sleep
    [1]   Done                    sleep 10
    [utest@foss-ssc-6 ~]$ stat -c "%u %g" /proc/$pid/
    0 0
    [utest@foss-ssc-6 ~]$ echo $pid

    [utest@foss-ssc-6 ~]$ stat -c "%u %g" /proc/2023432
    1008 1011
    [utest@foss-ssc-6 ~]$ id
    uid=1008(utest) gid=1011(utest) groups=1011(utest) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
    [utest@foss-ssc-6 ~]$

```
above is real UID and GID

**TIPS** How to check real UID GID of running process
```bash
$ egrep "^(U|G)id" /proc/$pid/status
Uid:    1000    1000    1000    1000
Gid:    1000    1000    1000    1000
```

* Effective User ID
  
  The effective UID (euid) of a process is used for most access checks. It is also used as the owner for files created by that process. The effective GID (egid) of a process also affects access control and may also affect file creation, depending on the semantics of the specific kernel implementation in use and possibly the mount options used. According to BSD Unix semantics, the group ownership given to a newly created file is unconditionally inherited from the group ownership of the directory in which it is created. According to AT&T UNIX System V semantics (also adopted by Linux variants), a newly created file is normally given the group ownership specified by the egid of the process that creates the file. Most filesystems implement a method to select whether BSD or AT&T semantics should be used regarding group ownership of a newly created file; BSD semantics are selected for specific directories when the S_ISGID (s-gid) permission is set.[1]

    Let's take the ping command as an example.

    Search for the binary location with the which command then run ls -la:

    ```bash
    > ls -la
    -rwsr-xr-x  1 root root   64424 Mar 10  2017  ping
    ```
    You can see that the owner and the group of the file are root. This is because the ping command needs to open up a socket and the Linux kernel demands root privilege for that.

    But how can I use ping if I don't have root privilege?

    Notice the 's' letter instead of 'x' in the owner part of the file permission.

    This is a special permission bit for specific binary executable files (like ping and sudo) which is known as setuid.

    This is where EUID and EGID come into play.

    What will happen is when a setuid binary like ping executes, the process changes its Effective User ID (EUID) from the default RUID to the owner of this special binary executable file which in this case is - root.

    This is all done by the simple fact that this file has the setuid bit.

    The kernel makes the decision whether this process has the privilege by looking on the EUID of the process. Because now the EUID points to root, the operation won't be rejected by the kernel.

    Notice: On latest Linux releases the output of the ping command will look different because of the fact that they adopted the Linux Capabilities approach instead of this setuid approach - for those who are not familiar - read here.

* Saved User ID
  
  The saved user ID (suid) is used when a program running with elevated privileges needs to do some unprivileged work temporarily; changing euid from a privileged value (typically 0) to some unprivileged value (anything other than the privileged value) causes the privileged value to be stored in suid.[3] Later, a program's euid can be set back to the value stored in suid, so that elevated privileges can be restored; an unprivileged process may set its euid to one of only three values: the value of ruid, the value of suid, or the value of euid. 

* File System User ID
  
  Linux also has a file system user ID (fsuid) which is used explicitly for access control to the file system. It matches the euid unless explicitly set otherwise. It may be root's user ID only if ruid, suid, or euid is root. Whenever the euid is changed, the change is propagated to the fsuid.

  The intent of fsuid is to permit programs (e.g., the NFS server) to limit themselves to the file system rights of some given uid without giving that uid permission to send them signals. Since kernel 2.0, the existence of fsuid is no longer necessary because Linux adheres to SUSv3 rules for sending signals, but fsuid remains for compatibility reasons.[2] 

# Thread capability sets

Each thread has the following capability sets containing zero or  more of the above capabilities

* Permitted
  
  This is a limiting **superset** for the effective capabilities that the thread may assume.  It is also a limiting superset for the capabilities that may be added to the inheritable set by a thread that does not have the CAP_SETPCAP capability in its effective set.

  If a thread drops a capability from its permitted set, it can never reacquire that capability (unless it execve(2)s either a set-user-ID-root program, or a program whose associated file capabilities grant that capability).

* Effective
  this is the set of capabilities used by the kernel to  perform permission checks for the thread.

```c
       #include <linux/capability.h> /* Definition of CAP_* and
                                        _LINUX_CAPABILITY_* constants */
       #include <sys/syscall.h>      /* Definition of SYS_* constants */
       #include <unistd.h>

       int syscall(SYS_capget, cap_user_header_t hdrp,
                   cap_user_data_t datap);
       int syscall(SYS_capset, cap_user_header_t hdrp,
                   const cap_user_data_t datap);

       // Note: glibc provides no wrappers for these system calls, necessitating the use of syscall(2).
```

https://man7.org/linux/man-pages/man2/capset.2.html


# File capabilites sets

* Permitted (formerly known as forced):
  
  These capabilities are automatically permitted to the thread, regardless of the thread's inheritable capabilities.

* Inheritable (formerly known as allowed):
  This set is ANDed with the thread's inheritable set to determine which inheritable capabilities are enabled in the permitted set of the thread after the execve(2).
              
* Effective:
  
  This is not a set, but rather just a single bit.  If this bit is set, then during an execve(2) all of the new permitted capabilities for the thread are also raised in the effective set.  If this bit is not set, then after an execve(2), none of the new permitted capabilities is in the new effective set.

              Enabling the file effective capability bit implies that
              any file permitted or inheritable capability that causes a
              thread to acquire the corresponding permitted capability
              during an execve(2) (see the transformation rules
              described below) will also acquire that capability in its
              effective set.  Therefore, when assigning capabilities to
              a file (setcap(8), cap_set_file(3), cap_set_fd(3)), if we
              specify the effective flag as being enabled for any
              capability, then the effective flag must also be specified
              as enabled for all other capabilities for which the
              corresponding permitted or inheritable flags is enabled.


# Capabilities and execution of programs by root

the kernel performs special treatment of file capabilities when a process with UID 0 (root) executes a program and when a set-user-ID-root program is executed.

1. If the real or effective user ID of the process is 0 (root), then the file inheritable and permitted sets are ignored; instead they are notionally considered to be all ones **(i.e., all capabilities enabled)**.  (There is one exception to this behavior, described below in Set-user-ID-root programs that have file capabilities.)
2. If the effective user ID of the process is 0 (root) or the file effective bit is in fact enabled, then the file effective bit is notionally defined to be one (enabled).

# Set-user-ID-root programs that have file capabilities

There is one exception to the behavior described under Capabilities and execution of programs by root.  If (a) the binary that is being executed has capabilities attached and (b) the real user ID of the process is not 0 (root) and (c) the effective user ID of the process is 0 (root), then the file capability bits are honored (i.e., they are not notionally considered to be all ones).  The usual way in which this situation can arise is when executing a set-UID-root program that also has file capabilities.  When such a program is executed, the process gains just the capabilities granted by the program (i.e., not all capabilities, as would occur when executing a set-user- ID-root program that does not have any associated file capabilities).

# How to find the capabilites that running process required

```bash
oot@eksa-2:~/pss# getpcaps 1225493
1225493: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap+i

root@eksa-2:~/pss# getpcaps 3540767
3540767: = cap_net_admin,cap_net_raw+p
root@eksa-2:~/pss# 

root@eksa-2:/proc/3545255# cat status | grep Cap
CapInh:	0000000000000000
CapPrm:	0000000000003000
CapEff:	0000000000000000
CapBnd:	0000003fffffffff
CapAmb:	0000000000000000

root@eksa-2:/proc/3545255# capsh --decode=0000000000003000
0x0000000000003000=cap_net_admin,cap_net_raw

root@eksa-2:~/pss# getpcaps 3541777
3541777: =
root@eksa-2:~/pss# 

root@eksa-2:~/pss# 


```

# How to find the capabilities that file execution required

```bash
root@eksa-2:/proc/3545255# getcap /usr/bin/ping
/usr/bin/ping = cap_net_raw+ep
root@eksa-2:/proc/3545255# 

```

# How to set capabilities

```bash
setcap 'cap_net_bind_service=+ep' /path/to/program
```

# File Attributes

* a: append only
* c: compressed
* d: no dump
* e: extent format
* i: immutable
* j: data journalling
* s: secure deletion
* t: no tail-merging
* u: undeletable
* A: no atime updates
* C: no copy on write
* D: synchronous directory updates
* S: synchronous updates
* T: top of directory hierarchy
* h: huge file
* E: compression error
* I: indexed directory
* X: compression raw access
* Z: compressed dirty file

## What is chattr and lsattr ?
chattr corresponds to “change attribute” and used to change few file/filesystem attributes.
lsattr corresponds to “list attribute” and used to list few file/filesystem attributes.

```bash
yum install e2fsprogs
```

## Why to use chattr and lsattr ?
There are multiple attributes with a filesystem, and with files on a filesystem in Linux. Some of the attributes are controlled by chmod command which changes files’ permissions, some are controlled by tune2fs to modify filesystem attributes.

And few of such attributes that control files behavior/access are handled by chattr and lsattr command.

Sometimes we need to change these attributes and hence chattr/lsattr commands are required

* To add the attribute we use “+”(addition sign) 
* to remove the attribute we use “-“(minus sign).

```bash
[root@foss-ssc-6 ~]# lsattr /etc/gshadow
-------------------- /etc/gshadow
[root@foss-ssc-6 ~]# chattr +i /etc/gshadow
[root@foss-ssc-6 ~]# lsattr /etc/gshadow
----i--------------- /etc/gshadow
[root@foss-ssc-6 ~]# groupadd def
groupadd: cannot open /etc/gshadow
[root@foss-ssc-6 ~]# 
[root@foss-ssc-6 ~]# chattr -i /etc/gshadow
[root@foss-ssc-6 ~]# groupadd def

[root@foss-ssc-6 ~]# chattr +i abc
[root@foss-ssc-6 ~]# rm -rf abc
rm: cannot remove 'abc': Operation not permitted
[root@foss-ssc-6 ~]# chattr -i abc
[root@foss-ssc-6 ~]# rm -rf abc
[root@foss-ssc-6 ~]# 


```

```bash
[root@foss-ssc-6 ~]# stat abc
  File: abc
  Size: 4         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 59254618    Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:admin_home_t:s0
Access: 2022-03-13 18:14:37.132957885 +0800
Modify: 2022-03-13 18:15:09.410243017 +0800
Change: 2022-03-13 18:15:09.410243017 +0800
 Birth: -
[root@foss-ssc-6 ~]# 

```

# File Time


* ctime: Shows file change time. Changes includes file content and mode
* atime: Shows file access time, read time
* mtime: Shows file modification time: Content changes
* crtime: Shows file creation time.

## How to find create time

https://access.redhat.com/solutions/61571


* The birth time or file creation time (crtime) is extension to the POSIX defined times mtime, atime and ctime. The file creation time (crtime) is not part of POSIX standard.
* The XFS filesystem does not have this feature implemented and there is no plan to add it in the future.
* The ext4 filesystem does record the creation- or birth-timestamp in the crtime field. This is implemented only on ext4 filesystem.
* The ext2 and ext3 filesystems do not record the creation time so it is not possible with ext2 and ext3.
* The stat command shows a "Birth" field, but it does not show the date stored in the crtime field.


```
    For XFS, there are no ways to see the crtime since it is not recorded.

    For EXT4, to see the crtime, use the debugfs command (from the e2fsprogs package) as root; You must tell debugfs to run stat against the inode number of the file in question and give it the filesystem on which the file resides. For example:
    Raw

    # ls -i testfile
    18 testfile
    # debugfs -w -R "stat <18>" /dev/sdb1 | grep crtime
    debugfs 1.42.9 (28-Dec-2013)
    crtime: 0x5b63029c:2d3367a4 -- Thu Aug  2 09:09:48 2018

    For EXT3 or EXT2, there are no ways to see the crtime since it is not recorded.

```
* Find inode
  ```bash
    [root@foss-ssc-6 ~]# stat createTime 
    File: createTime
    Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
    Device: fd00h/64768d	Inode: 59254616    Links: 1
    Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
    Context: unconfined_u:object_r:admin_home_t:s0
    Access: 2022-03-13 18:31:15.197694757 +0800
    Modify: 2022-03-13 18:31:15.197694757 +0800
    Change: 2022-03-13 18:31:15.197694757 +0800
    Birth: -

   [root@foss-ssc-6 ~]# ls -li createTime 
   59254616 -rw-r--r--. 1 root root 0 Mar 13 18:31 createTime

  ```
* Find file disk location
  ```bash
    [root@foss-ssc-6 ~]# df /root/createTime 
    Filesystem          1K-blocks     Used Available Use% Mounted on
    /dev/mapper/cl-root  52399104 27188280  25210824  52% /
    [root@foss-ssc-6 ~]# 

  ```
* debugfs
  The debugfs program is an interactive file system debugger. It can be used to examine and change the state of an **ext2, ext3, or ext4** file system.

  XFS does not support creation time. It just has the regular atime, mtime and ctime. There are no plans that I've heard to support it

  ```bash
    debugfs -R 'stat <14420015>' /dev/sda10

    Inode: 14420015   Type: regular    Mode:  0777   Flags: 0x80000
    Generation: 2130000141    Version: 0x00000000:00000001
    User:  1000   Group:  1000   Size: 260
    File ACL: 0    Directory ACL: 0
    Links: 1   Blockcount: 8
    Fragment:  Address: 0    Number: 0    Size: 0
    ctime: 0x579ed684:8fd54a34 -- Mon Aug  1 10:26:36 2016
    atime: 0x58aea120:3ec8dc30 -- Thu Feb 23 14:15:20 2017
    mtime: 0x5628ae91:38568be0 -- Thu Oct 22 15:08:25 2015
    crtime: 0x579ed684:8fd54a34 -- Mon Aug  1 10:26:36 2016
    Size of extra inode fields: 32
    EXTENTS:
    (0):57750808
    (END)
  ```

# Run tcpdump w/ Non-root
```bash
#!/usr/bin/env bash

# NOTE: This will let anyone who belongs to the 'pcap' group
# execute 'tcpdump'

# NOTE2: User running the script MUST be a sudoer. It is
# convenient to be able to sudo without a password.

sudo groupadd pcap
sudo usermod -a -G pcap $USER
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
sudo ln -s /usr/sbin/tcpdump /usr/bin/tcpdump
```


# Refereces

* https://man7.org/linux/man-pages/man7/capabilities.7.html
* 