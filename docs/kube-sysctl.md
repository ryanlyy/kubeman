Kuberntes & Container sysctl parameter configuration
---

- [Terms](#terms)
- [Enable unsafe sysctl](#enable-unsafe-sysctl)
  - [Admin Configuration](#admin-configuration)
  - [Pod Manfiest Update](#pod-manfiest-update)
  - [Docker Run Cmd](#docker-run-cmd)
- [PodSecurityPolicy](#podsecuritypolicy)
- [Linux sysctl of namespaced inside](#linux-sysctl-of-namespaced-inside)
  - [Namespaces](#namespaces)
  - [IPC Namespace](#ipc-namespace)
  - [NET Namespace](#net-namespace)
  - [PID Namespace](#pid-namespace)
  - [MNT Namespace](#mnt-namespace)
  - [UTS Namespace](#uts-namespace)
  - [User Namespace](#user-namespace)
- [References](#references)


This helper is used to sumamry all sysctl that kubernets and container supported.

# Terms
* safe sysctl
  
  A safe sysctl must be properly isolated between pods on the same node 
  * must not have any influence on any other pod on the node
  * must not allow to harm the node's health
  * must not allow to gain CPU or memory resources outside of the resource limits of a pod.
  
  By far, **most of the namespaced sysctls are not necessarily considered safe**. The following sysctls are supported in the safe set:
  * kernel.shm_rmid_forced,
  * net.ipv4.ip_local_port_range,
  * net.ipv4.tcp_syncookies,
  * net.ipv4.ping_group_range (since Kubernetes 1.18).

  **All safe sysctls are enabled by default**

* unsafe sysctl

  All unsafe sysctls are disabled by default and must be allowed manually by the cluster admin on a **per-node basis**. Pods with disabled unsafe sysctls will be scheduled, but will fail to launch

* Namespaced sysctl

  It means that they can be set independently for each pod on a node. **Only namespaced sysctls are configurable via the pod securityContext within Kubernetes**.

  * IPC Namespace:
    * kernel.msgmax, 
    * kernel.msgmnb, 
    * kernel.msgmni, 
    * kernel.sem, 
    * kernel.shmall, 
    * kernel.shmmax, 
    * kernel.shmmni, 
    * kernel.shm_rmid_forced
    * fs.mqueue.*

  * Network Namespace:
    * net.*

* Non-Namespaced sysctl - node-level sysctl
  
  If you need to set them, you must manually configure them on each node's operating system, or by using a DaemonSet with privileged containers

# Enable unsafe sysctl

## Admin Configuration
https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/kubelet/config/v1beta1/types.go: **KubeletConfiguration**

```
// A comma separated whitelist of unsafe sysctls or sysctl patterns (ending in *). Unsafe sysctl groups are :
    kernel.shm*, 
    kernel.msg*, 
    kernel.sem, 
    fs.mqueue.*, 
    net.*.
	// These sysctls are namespaced but not allowed by default.  For example: "kernel.msg*,net.ipv4.route.min_pmtu"
	// Default: []
	// +optional
	AllowedUnsafeSysctls []string `json:"allowedUnsafeSysctls,omitempty"`
```

## Pod Manfiest Update
**Only namespaced sysctls are configurable via the pod securityContext within Kubernetes**.
```
apiVersion: v1
kind: Pod
metadata:
  name: sysctl-example
spec:
  securityContext:
    sysctls:
    - name: kernel.shm_rmid_forced
      value: "0"
    - name: net.core.somaxconn
      value: "1024"
    - name: kernel.msgmax
      value: "65536"
  ...
```

## Docker Run Cmd

The --sysctl sets **namespaced** kernel parameters (sysctls) in the container. For example, to turn on IP forwarding in the containers network namespace, run this command:

```
$ docker run --sysctl net.ipv4.ip_forward=1 someimage
```

# PodSecurityPolicy
sysctls can be set in pods by specifying lists of sysctls or sysctl patterns in the **forbiddenSysctls** and/or **allowedUnsafeSysctls** fields of the **PodSecurityPolicy**. A sysctl pattern ends with a * character, such as kernel.*. A * character on its own matches all sysctls.

By default, all safe sysctls are allowed.

If you allow unsafe sysctls via the allowedUnsafeSysctls field in a PodSecurityPolicy, any pod using such a sysctl will fail to start if the sysctl is not allowed via the **--allowed-unsafe-sysctls** kubelet flag as well on that node

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: sysctl-psp
spec:
  allowedUnsafeSysctls:
  - kernel.msg*
  forbiddenSysctls:
  - kernel.shm_rmid_forced
```

# Linux sysctl of namespaced inside
## Namespaces
```
SYSCALL_DEFINE1 2510 return ksys_unshare(unshare_flags);

```
* unshare_flags
  * CLONE_FILES
  * CLONE_FS
  * CLONE_NEWCGROUP
  * **CLONE_NEWIPC**
  * **CLONE_NEWNET**
  * **CLONE_NEWNS**
    If unsharing MNT namespace, must also unshare filesystem information.
    ```
     unshare_flags |= CLONE_FS
    ```

  * **CLONE_NEWPID**
  * **CLONE_NEWUSER**
    If unsharing a user namespace must also unshare the **thread group** and unshare the **filesystem root and working directories**.
    ```
    unshare_flags |= CLONE_THREAD | CLONE_FS
    ```

  * **CLONE_NEWUTS**
  * CLONE_SYSVSEM
  * CLONE_THREAD
  * CLONE_SIGHAND
  * CLONE_VM

[Linux Namespace Insides](../mm/namespaces.mm)

## IPC Namespace
* SEM

  ```
  #define SEMMSL  32000           /* <= INT_MAX max num of semaphores per id   */
  #define SEMMNS  (SEMMNI*SEMMSL) /* <= INT_MAX max # of semaphores in system   */
  #define SEMOPM  500             /* <= 1 000 max num of ops per semop call */
  #define SEMMNI  32000           /* <= IPCMNI  max # of semaphore   identifiers */
  
  kernel.sem = 32000      1024000000      500     32000
  ```
  **hardcode** w/ default value of sysctl **"kernel.sem"** when creating new IPC namespace instead of inherit from its parents ipc namespace on kernel.sem

  ```
  [root@foss-ssc-7 ~]# sysctl -a  |grep sem
  kernel.sem = 32001      1024000000      500     32000
  kernel.sem_next_id = -1
  [root@foss-ssc-7 ~]# docker run --privileged --rm --name tstns -ti centos:7.  6.1810 bash
  [root@0c031aca9eb5 /]# sysctl -a  |grep sem
  kernel.sem = 32000      1024000000      500     32000
  ```
  when update sysctl in container, it will use **current** task namespace.   for example: ipc_namespace
  
  ```
  static void *get_ipc(struct ctl_table *table)
  {
          char *which = table->data;
          struct ipc_namespace *ipc_ns = current->nsproxy->ipc_ns;
          which = (which - (char *)&init_ipc_ns) + (char *)ipc_ns;
          return which;
  }
  ```

* MSG

  **hardcode** w/ default value of sysctl **"kernel.msg*"** when creating new IPC namespace instead of inherit from its parents ipc namespace on kernel.msg*

  ```
  #define MSGMNI 32000   /* <= IPCMNI */     /* max # of msg queue identifiers */
  #define MSGMAX  8192   /* <= INT_MAX */   /* max size of message (bytes) */
  #define MSGMNB 16384   /* <= INT_MAX */   /* default max size of a message queue */
  ```

  ```
  [root@foss-ssc-7 ~]# sysctl -w kernel.msgmax=8193
  kernel.msgmax = 8193
  [root@foss-ssc-7 ~]# docker run --privileged --rm --name tstns -ti centos:7.  6.1810 bash
  [root@05b4ce24259e /]# sysctl -a | grep msg
  kernel.msgmax = 8192
  kernel.msgmnb = 16384
  kernel.msgmni = 32000
  ```
* shm
  
  **hardcode** w/ default value of sysctl **"kernel.shm*"** when creating new IPC namespace instead of inherit from its parents ipc namespace on kernel.shm*
  ```
  #define SHMMNI 4096                      /* max num of segs system wide */
  #define SHMMAX (ULONG_MAX - (1UL << 24)) /* max shared seg size (bytes) */
  #define SHMALL (ULONG_MAX - (1UL << 24)) /* max shm system wide (pages) */
  ```
  ```
  [root@05b4ce24259e /]# sysctl -a | grep shm
  kernel.shmall = 18446744073692774399
  kernel.shmmax = 18446744073692774399
  kernel.shmmni = 4096
  ```
* mq
  
  **hardcode** w/ default value of sysctl **"fs.mqueue.*"** when creating new IPC namespace instead of inherit from its parents ipc namespace on fs.mqueue.*
  ```
  #define DFLT_QUEUESMAX                256
  #define DFLT_MSG                       10U
  #define DFLT_MSGMAX                    10
  #define DFLT_MSGSIZE                 8192U
  #define DFLT_MSGSIZEMAX              8192
  ```
  ```
  fs.mqueue.msg_default = 10
  fs.mqueue.msg_max = 10
  fs.mqueue.msgsize_default = 8192
  fs.mqueue.msgsize_max = 8192
  fs.mqueue.queues_max = 256
  ```
## NET Namespace
* sysctl parameter list
  ```
  [root@foss-ssc-7 ~]# sysctl -a | grep "^net" | cut -d "." -f1-2 | sort -u
  net.bridge
  net.core
  net.ipv4
  net.ipv6
  net.netfilter
  net.nf_conntrack_max
  net.unix
  [root@foss-ssc-7 ~]#
  ```
* net_namespace_list

  ```
  LIST_HEAD(net_namespace_list);
  EXPORT_SYMBOL_GPL(net_namespace_list);
  ```

* pernet_list
  * network namespace constructor/destructor lists
  ```
  static LIST_HEAD(pernet_list);
  static struct list_head *first_device = &pernet_list;
  ```
  * initialization
    
    **When a new network namespace is created all of the init methods are called in the order in which they were registered.**
    ```
    /**
     *      register_pernet_subsys - register a network namespace subsystem
     *      @ops:  pernet operations structure for the subsystem
     *
     *      Register a subsystem which has init and exit functions
     *      that are called when network namespaces are created and
     *      destroyed respectively.
     *
     *      When registered all network namespace init functions are
     *      called for every existing network namespace.  Allowing kernel
     *      modules to have a race free view of the set of network namespaces.
     *
     *      When a new network namespace is created all of the init
     *      methods are called in the order in which they were registered.
     *
     *      When a network namespace is destroyed all of the exit methods
     *      are called in the reverse of the order with which they were
     *      registered.
     */
    int register_pernet_subsys(struct pernet_operations *ops)
    {
            int error;
            down_write(&pernet_ops_rwsem);
            error =  register_pernet_operations(first_device, ops);
            up_write(&pernet_ops_rwsem);
            return error;
    }

    ```
    **When a new network namespace is created all of the init methods are called in the order in which they were registered**
    ```   
    /**
     *      register_pernet_device - register a network namespace device
     *      @ops:  pernet operations structure for the subsystem
     *
     *      Register a device which has init and exit functions
     *      that are called when network namespaces are created and
     *      destroyed respectively.
     *
     *      When registered all network namespace init functions are
     *      called for every existing network namespace.  Allowing kernel
     *      modules to have a race free view of the set of network namespaces.
     *
     *      When a new network namespace is created all of the init
     *      methods are called in the order in which they were registered.
     *
     *      When a network namespace is destroyed all of the exit methods
     *      are called in the reverse of the order with which they were
     *      registered.
     */
    int register_pernet_device(struct pernet_operations *ops)
    {
            int error;
            down_write(&pernet_ops_rwsem);
            error = register_pernet_operations(&pernet_list, ops);
            if (!error && (first_device == &pernet_list))
                    first_device = &ops->list;
            up_write(&pernet_ops_rwsem);
            return error;
    }
    ```
    **IPV4**

    **Example of pernet subsys**
    ```
    -- fs_initcall(inet_init);
      -- ip_init
        -- ip_rt_init
          -- devinet_init
            -- register_pernet_subsys(&devinet_ops);
              -- register_pernet_operations(first_device, ops)

    static __net_initdata struct pernet_operations devinet_ops = {
        .init = devinet_init_net,
        .exit = devinet_exit_net,
    };
        
    ```
    SOMAXCONN
    ```
    static int __net_init net_defaults_init_net(struct net *net)
    {
            net->core.sysctl_somaxconn = SOMAXCONN;
            return 0;
    }
    
    static struct pernet_operations net_defaults_ops = {
            .init = net_defaults_init_net,
    };
    
    static __init int net_defaults_init(void)
    {
            if (register_pernet_subsys(&net_defaults_ops))
                    panic("Cannot initialize net default settings");
    
            return 0;
    }
    
    core_initcall(net_defaults_init);
    ```
  **Example of pernet dev**
  ```
  -- subsys_initcall(net_dev_init);
    -- register_pernet_device(&loopback_net_ops)
    -- register_pernet_device(&default_device_ops))

  /* The loopback device is special if any other network devices
   * is present in a network namespace the loopback device must
   * be present. Since we now dynamically allocate and free the
   * loopback device ensure this invariant is maintained by
   * keeping the loopback device as the first device on the
   * list of network devices.  Ensuring the loopback devices
   * is the first device that appears and the last network device
   * that disappears.
   */
  ```
  **IPV6**

  **Example of ipv6 stack**
  ```
  -- module_init(inet6_init);
    -- addrconf_init()
      -- idev = ipv6_add_dev(init_net.loopback_dev);
        -- memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
  ``` 
* devconf_all & devconf_dflt
  * ipv4
    ```
    static __net_init int devinet_init_net(struct net *net)
    {
            int err;
            struct ipv4_devconf *all, *dflt;
    #ifdef CONFIG_SYSCTL
            struct ctl_table *tbl = ctl_forward_entry;
            struct ctl_table_header *forw_hdr;
    #endif
    
            err = -ENOMEM;
            all = &ipv4_devconf;
            dflt = &ipv4_devconf_dflt;
             ...
            net->ipv4.devconf_all = all;
            net->ipv4.devconf_dflt = dflt;
            return 0;
    
    ```
    dflt value
    ```
    static struct ipv4_devconf ipv4_devconf_dflt = {
        .data = {
                [IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
                [IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
                [IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
                [IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
                [IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE - 1] = 1,
                [IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL - 1] = 10000 /*ms*/,
                [IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL - 1] =  1000 /*ms*/,
        },
    };
    ```
    all value
    ```
    static struct ipv4_devconf ipv4_devconf = {
        .data = {
                [IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
                [IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
                [IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
                [IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
                [IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL - 1] = 10000 /*ms*/,
                [IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL - 1] =  1000 /*ms*/,
        },
    }
    ```
  * ipv6
    ```
    static int __net_init addrconf_init_net(struct net *net)
    {
        int err = -ENOMEM;
        struct ipv6_devconf *all, *dflt;

        all = kmemdup(&ipv6_devconf, sizeof(ipv6_devconf), GFP_KERNEL);
        if (!all)
                goto err_alloc_all;

        dflt = kmemdup(&ipv6_devconf_dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
        if (!dflt)
                goto err_alloc_dflt;

        /* these will be inherited by all namespaces */
        dflt->autoconf = ipv6_defaults.autoconf;
        dflt->disable_ipv6 = ipv6_defaults.disable_ipv6;

        dflt->stable_secret.initialized = false;
        all->stable_secret.initialized = false;

        net->ipv6.devconf_all = all;
        net->ipv6.devconf_dflt = dflt;
        ...
    }
    ```
    dflt value
    ```
    static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
        .forwarding             = 0,
        .hop_limit              = IPV6_DEFAULT_HOPLIMIT,
        .mtu6                   = IPV6_MIN_MTU,
        .accept_ra              = 1,
        .accept_redirects       = 1,
        .autoconf               = 1,
        .force_mld_version      = 0,
        .mldv1_unsolicited_report_interval = 10 * HZ,
        .mldv2_unsolicited_report_interval = HZ,
        .dad_transmits          = 1,
        .rtr_solicits           = MAX_RTR_SOLICITATIONS,
        .rtr_solicit_interval   = RTR_SOLICITATION_INTERVAL,
        .rtr_solicit_max_interval = RTR_SOLICITATION_MAX_INTERVAL,
        .rtr_solicit_delay      = MAX_RTR_SOLICITATION_DELAY,
        .use_tempaddr           = 0,
        .temp_valid_lft         = TEMP_VALID_LIFETIME,
        .temp_prefered_lft      = TEMP_PREFERRED_LIFETIME,
        .regen_max_retry        = REGEN_MAX_RETRY,
        .max_desync_factor      = MAX_DESYNC_FACTOR,
        .max_addresses          = IPV6_MAX_ADDRESSES,
        .accept_ra_defrtr       = 1,
        .accept_ra_from_local   = 0,
        .accept_ra_min_hop_limit= 1,
        .accept_ra_pinfo        = 1,
        #ifdef CONFIG_IPV6_ROUTER_PREF
        .accept_ra_rtr_pref     = 1,
        .rtr_probe_interval     = 60 * HZ,
        #ifdef CONFIG_IPV6_ROUTE_INFO
        .accept_ra_rt_info_min_plen = 0,
        .accept_ra_rt_info_max_plen = 0,
        #endif
        #endif
        .proxy_ndp              = 0,
        .accept_source_route    = 0,    /* we do not accept RH0 by default. */
        .disable_ipv6           = 0,
        .accept_dad             = 1,
        .suppress_frag_ndisc    = 1,
        .accept_ra_mtu          = 1,
        .stable_secret          = {
                .initialized = false,
        },
        .use_oif_addrs_only     = 0,
        .ignore_routes_with_linkdown = 0,
        .keep_addr_on_down      = 0,
        .seg6_enabled           = 0,
        #ifdef CONFIG_IPV6_SEG6_HMAC
        .seg6_require_hmac      = 0,
        #endif
        .enhanced_dad           = 1,
        .addr_gen_mode          = IN6_ADDR_GEN_MODE_EUI64,
        .disable_policy         = 0,
    };
    ```
    all value
    ```
    static struct ipv6_devconf ipv6_devconf __read_mostly = {
        .forwarding             = 0,
        .hop_limit              = IPV6_DEFAULT_HOPLIMIT,
        .mtu6                   = IPV6_MIN_MTU,
        .accept_ra              = 1,
        .accept_redirects       = 1,
        .autoconf               = 1,
        .force_mld_version      = 0,
        .mldv1_unsolicited_report_interval = 10 * HZ,
        .mldv2_unsolicited_report_interval = HZ,
        .dad_transmits          = 1,
        .rtr_solicits           = MAX_RTR_SOLICITATIONS,
        .rtr_solicit_interval   = RTR_SOLICITATION_INTERVAL,
        .rtr_solicit_max_interval = RTR_SOLICITATION_MAX_INTERVAL,
        .rtr_solicit_delay      = MAX_RTR_SOLICITATION_DELAY,
        .use_tempaddr           = 0,
        .temp_valid_lft         = TEMP_VALID_LIFETIME,
        .temp_prefered_lft      = TEMP_PREFERRED_LIFETIME,
        .regen_max_retry        = REGEN_MAX_RETRY,
        .max_desync_factor      = MAX_DESYNC_FACTOR,
        .max_addresses          = IPV6_MAX_ADDRESSES,
        .accept_ra_defrtr       = 1,
        .accept_ra_from_local   = 0,
        .accept_ra_min_hop_limit= 1,
        .accept_ra_pinfo        = 1,
        #ifdef CONFIG_IPV6_ROUTER_PREF
        .accept_ra_rtr_pref     = 1,
        .rtr_probe_interval     = 60 * HZ,
        #ifdef CONFIG_IPV6_ROUTE_INFO
        .accept_ra_rt_info_min_plen = 0,
        .accept_ra_rt_info_max_plen = 0,
        #endif
        #endif
        .proxy_ndp              = 0,
        .accept_source_route    = 0,    /* we do not accept RH0 by default. */
        .disable_ipv6           = 0,
        .accept_dad             = 0,
        .suppress_frag_ndisc    = 1,
        .accept_ra_mtu          = 1,
        .stable_secret          = {
                .initialized = false,
        },
        .use_oif_addrs_only     = 0,
        .ignore_routes_with_linkdown = 0,
        .keep_addr_on_down      = 0,
        .seg6_enabled           = 0,
        #ifdef CONFIG_IPV6_SEG6_HMAC
        .seg6_require_hmac      = 0,
        #endif
        .enhanced_dad           = 1,
        .addr_gen_mode          = IN6_ADDR_GEN_MODE_EUI64,
        .disable_policy         = 0,
    };
    ```
* New Device
  * NS 1 
    ```
    -- e1000_probe
      -- register_netdev(netdev)
        -- register_netdevice(dev)
    ```
  * NEW DEVICE
    ```
    -- core_initcall(netlink_proto_init);
      -- rtnetlink_init()
        -- rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, 0);
          -- rtnl_newlink
            -- register_netdevice(dev);
    ```
  * register_netdevice(dev) - register a network device and add it to kernel interface
    ```
    -- register_netdevice(dev);
      --  call_netdevice_notifiers(NETDEV_REGISTER, dev)  /* Notify protocols, that a new device appeared. */
    ```
  * register_netdevice_notifier
    * IPv4: devinet_init -- ip_netdev_notifier - inetdev_event
      * NETDEV_REGISTER - inetdev_init(dev)
        ```
        in_dev = kzalloc(sizeof(*in_dev), GFP_KERNEL)
    
        memcpy(&in_dev->cnf, dev_net(dev)->ipv4.devconf_dflt,                    sizeof(in_dev->cnf));
        ```
    * IPv6: addrconf_init -- ipv6_dev_notf -- addrconf_notify
      * NETDEV_REGISTER - ipv6_add_dev(dev)
* libcontainer
  ```
  func (l *loopback) initialize(config *network) error {
        return netlink.LinkSetUp(&netlink.Device{LinkAttrs: netlink.LinkAttrs{Name: "lo"}})
  }
  ```
## PID Namespace
## MNT Namespace

## UTS Namespace
## User Namespace

# References
* [Kernel Sysctl Document](https://www.kernel.org/doc/Documentation/sysctl/)