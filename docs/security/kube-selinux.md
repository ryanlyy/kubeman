SELinux
---

permissin check sequence: DAC - MAC (if enabled)

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/getting-started-with-selinux_using-selinux

# SELinux
Security-Enhanced Linux (SELinux) is a security architecture for Linux® systems that allows administrators to have more control over who can access the system

SELinux defines access controls for the applications, processes, and files on a system. It uses security policies, which are a set of rules that tell SELinux what can or can’t be accessed, to enforce the access allowed by a policy. 

## Concepts - SELinux labeling and type enforcement

### Label
SELinux works as a labeling system, which means that all of the files, processes, and ports in a system have an SELinux label associated with them. 

Labels are a logical way of grouping things together. The kernel manages the labels during boo

Label Format:

user:role:type:level (level is optional)

* User, role, and level are used in more advanced implementations of SELinux, like with MLS. 
* Label type is the most important for targeted policy. 

### Type Enforcement
type enforcement to enforce a policy that is defined on the system. Type enforcement is the part of an SELinux policy that defines 

-- whether a process running with a certain type can access a file labeled with a certain type

## Configuration

When SELinux is in enforcing mode, the default policy is the targeted policy

* setenforce
* getenforce

```bash
[1/9 13:59] Rakesh Kumar T (Nokia)
[root@fin-707-edgebm-0 ~]# cat /etc/sysconfig/selinux
SELINUX=enforcing
SELINUXTYPE=targeted
[root@fin-707-edgebm-0 ~]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      33
[root@fin-707-edgebm-0 ~]#
```
```bash
[root@hpg10ncs-hpg10ncs-masterbm-0 sysconfig (Active)]# cat /etc/selinux/config 
SELINUX=enforcing
SELINUXTYPE=targeted
[root@hpg10ncs-hpg10ncs-masterbm-0 sysconfig (Active)]# cat /etc/sysconfig/selinux 
SELINUX=enforcing
SELINUXTYPE=targeted
[root@hpg10ncs-hpg10ncs-masterbm-0 sysconfig (Active)]# 
```
```bash
access("/etc/selinux/config", F_OK)     = 0
open("/sys/fs/selinux/enforce", O_RDONLY) = 3
```

```bash
[ryliu@CentosBuildServer01 ~]$ cat /etc/sysconfig/selinux

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 
```
* Targeted policy is the default option and covers a range of processes, tasks, and services. 
* MLS can be very complicated and is typically only used by government organizations. 

## semanage tool
```bash
[root@hpg10ncs-hpg10ncs-edgebm-1 ~]# rpm -ql libselinux-utils-2.5-15.el7.x86_64
/usr/sbin/avcstat
/usr/sbin/getenforce
/usr/sbin/getsebool
/usr/sbin/matchpathcon
/usr/sbin/selabel_digest
/usr/sbin/selabel_lookup
/usr/sbin/selabel_lookup_best_match
/usr/sbin/selabel_partial_match
/usr/sbin/selinux_restorecon
/usr/sbin/selinuxconlist
/usr/sbin/selinuxdefcon
/usr/sbin/selinuxenabled
/usr/sbin/selinuxexeccon
/usr/sbin/setenforce

rpm -ql policycoreutils-python-2.5-34.el7.x86_64
/usr/sbin/semanage
/usr/share/bash-completion/completions/semanage
/usr/share/bash-completion/completions/setsebool
```
```bash
[root@hpg10ncs-hpg10ncs-edgebm-1 sbin]# semanage --help
usage: semanage [-h]
                
                {import,export,login,user,port,ibpkey,ibendport,interface,module,node,fcontext,boolean,permissive,dontaudit}
                ...

semanage is used to configure certain elements of SELinux policy with-out
requiring modification to or recompilation from policy source.

positional arguments:
  {import,export,login,user,port,ibpkey,ibendport,interface,module,node,fcontext,boolean,permissive,dontaudit}
    import              Import local customizations
    export              Output local customizations
    login               Manage login mappings between linux users and SELinux
                        confined users
    user                Manage SELinux confined users (Roles and levels for an
                        SELinux user)
    port                Manage network port type definitions
    ibpkey              Manage infiniband ibpkey type definitions
    ibendport           Manage infiniband end port type definitions
    interface           Manage network interface type definitions
    module              Manage SELinux policy modules
    node                Manage network node type definitions
    fcontext            Manage file context mapping definitions
    boolean             Manage booleans to selectively enable functionality
    permissive          Manage process type enforcement mode
    dontaudit           Disable/Enable dontaudit rules in policy

optional arguments:
  -h, --help            show this help message and exit
```
[SELinux Export Output](./selinux-export.output)

# Discretionary Access Control (DAC) 

With DAC, files and processes have owners

DAC is identity-based access control. DAC mechanisms will be controlled by user identification such as username and password. DAC is discretionary because the owners can transfer objects or any authenticated information to other users. In simple words, the owner can determine the access privileges

DAC governs the ability of subjects to access object

The root user has full access control with a DAC system

The standard access policy based on the user, group, and other permissions, known as Discretionary Access Control (DAC),

# Mandatory Access Control (MAC)
Security-Enhanced Linux (SELinux) is an implementation of MAC in the Linux kernel, checking for allowed operations after standard discretionary access controls (DAC) are checked

SELinux can enforce a user-customizable security policy on running processes and their actions, including attempts to access file system objects. 

SELinux limits the scope of potential damage that can result from the exploitation of vulnerabilities in applications and system services

Mandatory Access Control (MAC) is a type of access control in which the operating system is used to:
 -- constrain 
 -- -- a user or process (the subject) 
 -- from 
 -- -- accessing or performing an operation on 
 -- an object (such as a file, disk, memory, socket, etc.).

 Note 
 1. that the subject (and therefore the user) cannot decide to bypass the policy rules being enforced by the MAC policy with SELinux enabled
 2. DAC allows users to make policy decisions

SELinux supports two forms of MAC
## Type Enforcement
Where processes run in domains and the actions on objects are controlled by policy. This is the implementation used for general purpose MAC within SELinux along with Role Based Access Control. 

## Multi-Level Security
 This is an implementation based on the Bell-La Padula (BLP) model, and used by organizations where different levels of access are required so that restricted information is separated from classified information to maintain confidentiality. This allows enforcement rules such as 'no write down' and 'no read up' to be implemented in a policy by extending the security context to include security levels

### A variant called Multi-Category Security (MCS) 

# SELinux Kubenetes
* Level
* Role
* Type
* User
  
```
securityContext.seLinuxOptions (SELinuxOptions)

The SELinux context to be applied to the container. If unspecified, the container runtime will allocate a random SELinux context for each container. May also be set in PodSecurityContext. If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence. Note that this field cannot be set when spec.os.name is windows.

SELinuxOptions are the labels to be applied to the container

securityContext.seLinuxOptions.level (string)

Level is SELinux level label that applies to the container.

securityContext.seLinuxOptions.role (string)

Role is a SELinux role label that applies to the container.

securityContext.seLinuxOptions.type (string)

Type is a SELinux type label that applies to the container.

securityContext.seLinuxOptions.user (string)

User is a SELinux user label that applies to the container.
```

NOTE: Below is based on k8s 1.25

staging/src/k8s.io/pod-security-admission/policy/check_seLinuxOptions.go

```golang
/*
Setting the SELinux type is restricted, and setting a custom SELinux user or role option is forbidden.

**Restricted Fields:**
spec.securityContext.seLinuxOptions.type
spec.containers[*].securityContext.seLinuxOptions.type
spec.initContainers[*].securityContext.seLinuxOptions.type

**Allowed Values:**
undefined/empty
container_t
container_init_t
container_kvm_t

**Restricted Fields:**
spec.securityContext.seLinuxOptions.user
spec.containers[*].securityContext.seLinuxOptions.user
spec.initContainers[*].securityContext.seLinuxOptions.user
spec.securityContext.seLinuxOptions.role
spec.containers[*].securityContext.seLinuxOptions.role
spec.initContainers[*].securityContext.seLinuxOptions.role

**Allowed Values:** undefined/empty
*/

```
* seLinuxOptions.type
  * undefined/empty
  * container_t
  * container_init_t
  * container_kvm_t

```golang
  selinux_allowed_types_1_0 = sets.NewString("", "container_t", "container_init_t", "container_kvm_t")
```

* seLinuxOptions.user
  * undefined/empty

* seLinuxOptions.role
  * undefined/empty

```golang

        validSELinuxOptions := func(opts *corev1.SELinuxOptions) bool {
                valid := true
                if !selinux_allowed_types_1_0.Has(opts.Type) {
                        valid = false
                        badTypes.Insert(opts.Type)
                }
                if len(opts.User) > 0 {
                        valid = false
                        setUser = true
                }
                if len(opts.Role) > 0 {
                        valid = false
                        setRole = true
                }
                return valid
        }
```
# How does SELinux works
SELinux is a labeling system and SELinux cares only about labels. From the SELinux point of view each **object** on the system has an **SELinux label**

* Objects
  * file
  * directory
  * socket file
  * symlink
  * shared memory
  * semaphore
  * fifo file
  * etc.
  * subject 
    * running process
    * Linux user entity

For example:
* file

/etc/passwd: system_u:object_r:passwd_file_t:s0

* Container Process

system_u:system_r:container_t:s0:c940,c967

  * system_u: a SELinux User (not same with Linux user) (several Linux users can be mapped to a single SELinux user); system_u user can be limited to a set of SELinux role
  * passwd_file_t|container_t: SELinux Type
  * 

SELinux Role: allow container_t container_file_t:file {getattr open read}; 

every process labeled as container_t can get attributes, open and read any file labeled as container_file_t on the filesystem

With MCS:
* the SystemLow sensitivity label is s0 
* the SystemHigh sensitivity label is s0:c0.c1023 
  
with MLS:
* SystemLow (s0) 
* SystemHigh s15:c0.c255. 

References
* https://www.redhat.com/en/blog/how-selinux-separates-containers-using-multi-level-security
* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/mls
* 