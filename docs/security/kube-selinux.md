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

