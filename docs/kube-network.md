Kubernetes Networking
---------------

- [network namespace creation](#network-namespace-creation)
- [lo with 127.0.0.1 and ::1](#lo-with-127001-and-1)
- [Ingress and Controller](#ingress-and-controller)
- [Egress](#egress)
- [Network Policy](#network-policy)
  
# network namespace creation
```bash
linux-5.4.45:
/* 0 - Keep current behavior:
 *     IPv4: inherit all current settings from init_net
 *     IPv6: reset all settings to default
 * 1 - Both inherit all current settings from init_net
 * 2 - Both reset all settings to default
 */
int sysctl_devconf_inherit_init_net __read_mostly;
```
net.core.devconf_inherit_init_net = 0

pure_initcall(net_ns_init);

net_ns_init is used to init network namespace as entry

setup_net(&init_net, &init_user_ns)


```bash
struct net init_net = {
        .count          = REFCOUNT_INIT(1),
        .dev_base_head  = LIST_HEAD_INIT(init_net.dev_base_head),
};
EXPORT_SYMBOL(init_net);


/*
 * setup_net runs the initializers for the network namespace object.
 */
static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
{

```

IPv4 default and all sysctl configuration
```bash
        all = &ipv4_devconf;
        dflt = &ipv4_devconf_dflt;

        err = __devinet_sysctl_register(net, "all", NETCONFA_IFINDEX_ALL, all);
        if (err < 0)
                goto err_reg_all;

        err = __devinet_sysctl_register(net, "default",
                                        NETCONFA_IFINDEX_DEFAULT, dflt);

        net->ipv4.devconf_all = all;
        net->ipv4.devconf_dflt = dflt;

```

IPv6 default and all sysctl configuration
```bash

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


struct ipv6_params ipv6_defaults = {
        .disable_ipv6 = 0,
        .autoconf = 1,
};

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

```

# lo with 127.0.0.1 and ::1
When kernel detects device with flag as LOOPBACK, it will automatically add 127.0.0.1 to lo. And ::1 will be added too but it is controlled by net.ipv6.conf.lo.disable_ipv6.

```bash
root@k8s-controler-1:~# ip netns add netns
root@k8s-controler-1:~# ip netns exec newns sysctl -w net.ipv6.conf.lo.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6 = 1
root@k8s-controler-1:~# ip netns exec newns ip link set lo up
root@k8s-controler-1:~# ip netns exec newns ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
root@k8s-controler-1:~# ip netns exec newns sysctl -w net.ipv6.conf.lo.disable_ipv6=0
net.ipv6.conf.lo.disable_ipv6 = 0
root@k8s-controler-1:~# ip netns exec newns ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
root@k8s-controler-1:~# ip netns exec newns sysctl -w net.ipv6.conf.lo.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6 = 1
root@k8s-controler-1:~# ip netns exec newns ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
```

When using runc, it will call LinkSetUp, when kernel received NETDEV_UP event, it will add 127.0.0.1 and ::1 (controlled disabled_ipv6)
```golang
func (l *loopback) initialize(config *network) error {
        return netlink.LinkSetUp(&netlink.Device{LinkAttrs: netlink.LinkAttrs{Name: "lo"}})
}
```
Kernel code for ipv4:
```bash
        case NETDEV_UP:
                if (!inetdev_valid_mtu(dev->mtu))
                        break;
                if (dev->flags & IFF_LOOPBACK) {
                        struct in_ifaddr *ifa = inet_alloc_ifa();

                        if (ifa) {
                                INIT_HLIST_NODE(&ifa->hash);
                                ifa->ifa_local =
                                  ifa->ifa_address = htonl(INADDR_LOOPBACK);
                                ifa->ifa_prefixlen = 8;
                                ifa->ifa_mask = inet_make_mask(8);
                                in_dev_hold(in_dev);
                                ifa->ifa_dev = in_dev;
                                ifa->ifa_scope = RT_SCOPE_HOST;
                                memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
                                set_ifa_lifetime(ifa, INFINITY_LIFE_TIME,
                                                 INFINITY_LIFE_TIME);
                                ipv4_devconf_setall(in_dev);
                                neigh_parms_data_state_setall(in_dev->arp_parms);
                                inet_insert_ifa(ifa);
                        }
                }
```
Kernel code for ipv6
```bash
        case NETDEV_UP:
        case NETDEV_CHANGE:
                if (dev->flags & IFF_SLAVE)
                        break;

                if (idev && idev->cnf.disable_ipv6)
                        break;
...
                case ARPHRD_LOOPBACK:
                        init_loopback(dev);
                        break;

static void init_loopback(struct net_device *dev)
{
        struct inet6_dev  *idev;

        /* ::1 */

        ASSERT_RTNL();

        idev = ipv6_find_idev(dev);
        if (!idev) {
                pr_debug("%s: add_dev failed\n", __func__);
                return;
        }

        add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
}

```

# Ingress and Controller
Ingress may provide load balancing, SSL termination and name-based virtual hosting

# Egress
# Network Policy
