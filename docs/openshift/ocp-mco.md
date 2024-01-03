Here is to describe mcp related knowledge
---
- [Understanding the Machine Config Operator (MCO)](#understanding-the-machine-config-operator-mco)
- [What MCO can do - rendered](#what-mco-can-do---rendered)
- [How to check MCO Health](#how-to-check-mco-health)
- [Another way to check ClusterOperator Machine-config status](#another-way-to-check-clusteroperator-machine-config-status)
- [Monitoring MCO Update](#monitoring-mco-update)
- [Troubleshotting Degraded Node](#troubleshotting-degraded-node)
  - [How to check node degrade status](#how-to-check-node-degrade-status)
- [How to force node use specific MC](#how-to-force-node-use-specific-mc)
- [CRD managed by MCC](#crd-managed-by-mcc)
- [KubeletConfig](#kubeletconfig)
- [Machine APIs](#machine-apis)
  - [ContainerRuntimeConfig](#containerruntimeconfig)
  - [KubeletConfig](#kubeletconfig-1)
  - [MachineConfigPoolSpec](#machineconfigpoolspec)
- [MachineConfig](#machineconfig)
  - [Final Rendered MachineConfig object](#final-rendered-machineconfig-object)
  - [MachineConfigController](#machineconfigcontroller)
  - [TemplateController](#templatecontroller)
  - [UpdateController](#updatecontroller)
  - [RenderController](#rendercontroller)
  - [KubeletConfigController](#kubeletconfigcontroller)
  - [MachineSets vs MachineConfigPool](#machinesets-vs-machineconfigpool)
- [MachineConfigDaemon](#machineconfigdaemon)
- [MachineConfigPool](#machineconfigpool)


# Understanding the Machine Config Operator (MCO)
* **machine-config-operator -- MCO** - this is the main controller loop or ClusterOperator itself that deploys and  manages everything else in this namespace.
* **machine-config-server -- MCS** - provides the endpoint that nodes connect to in order to get their configuration files.
* **machine-config-controller -- MCC** - co-ordinates upgrades and manages the lifecycle of nodes in the cluster by rendering (generating) MachineConfigs (mc), managing MachineConfigPools (mcp) and by co-ordinating with the machine-config-daemon running on each node to keep all the nodes up to date with the correct configuration.
* **machine-config-daemon -- MCD** - responsible for updating nodes to a given MachineConfig when requested to by the machine-config-controller. This runs as a DaemonSet so there is one pod per node in the cluster

All the OS configuration files a node requires are encoded and encapsulated in **ignition files**

The **machine-config-controller** collates all these various snippets and OS configuration files each node requires, and then **renders (generates)** MachineConfig kubernetes resources with all the files.

when the cluster was first installed, initial MachineConfigs were rendered - 
* one for the master nodes (rendered-master-0a540f..) in the cluster, 
* and one for the worker nodes (rendered-worker-9da78a...). 

Whilst these two MachineConfigs share common OS configuration files, there are also lots of differences and so they are managed separately for each MachineConfigPool.

As well as OCP version updates forcing updates, you can also **manually edit MachineConfigs** to modify or add you own OS config files. 

When a new MachineConfig is generated, the **machine-config-controller** will work with the **machine-config-daemon** running on each node to reboot it and have it apply the latest ignition configuration held within the MachineConfig

When a node boots Red Hat CoreOS, ignition connects to the **machine-config-server** endpoint https://<cluster-api>:22623/config/master (or /config/worker for worker nodes, or /config/<machine-config-pool>) and applies the Ignition config to the node

Manual changes to nodes are strongly **discouraged**. If you need to decommission a node and start a new one, those direct changes would be lost.

MCO is only supported for writing to files in **/etc and /var** directories, although there are symbolic links to some directories that can be writeable by being symbolically linked to one of those areas. The /opt and /usr/local directories are examples

When a file managed by MCO changes outside of MCO, the Machine Config Daemon (MCD) sets the node as **degraded**. It will not overwrite the offending file, however, and should continue to operate in a degraded state.

 A degraded node is online and operational, but, it cannot be updated.

There might be situations where the configuration on a node does not fully match what the currently-applied machine config specifies. This state is called configuration **drift**. The Machine Config Daemon (MCD) regularly checks the nodes for configuration drift. If the MCD detects configuration drift, the MCO marks the node degraded until an administrator corrects the node configuration

# What MCO can do - rendered
* baseOSExtensionsContainerImage
* config: create ignition config objects to do thins like mdoify files, systemd services and other featurs
  * ignition
  * passwd
  * storage - files - contents
    ```yaml
      - contents:
          source: data:,infra
        mode: 420
        overwrite: true
        path: /etc/infratest
    ```
  * systemd 
* extensions
* fips
* kernelArguments
* kernelType
* osImageURL


* Custom Resources
  * container runtime
  * kubelet
  * controller




# How to check MCO Health
```bash
[root@ce0128-ccmmt-master-0 ~]# oc get co machine-config
NAME             VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
machine-config   4.14.0    True        False         True       20d     Failed to resync 4.14.0 because: error during syncRequiredMachineConfigPools: [context deadline exceeded, failed to update clusteroperator: [client rate limiter Wait returned an error: context deadline exceeded, error MachineConfigPool worker is not ready, retrying. Status: (pool degraded: true total: 11, ready 0, updated: 0, unavailable: 11)]]
[root@ce0128-ccmmt-master-0 ~]#

```
* AVAIABLE
  * True: MCO is healthy
  * False: something wrong with cluster or in upgrade state
* PROGRESSING
  * False: No update and  that the nodes in your cluster are all up to date and running on the latest OS version and using all the OS config files from the MachineConfig
  * True: means the machine-config-controller is busy working through an update and asking the machine-config-daemons on each node to reboot the node and apply a MachineConfig.
* DEGRADED
  * False: healthy
  * True: problem that usually requires manual intervention

# Another way to check ClusterOperator Machine-config status 
```bash
[root@ce0128-ccmmt-master-0 ~]# oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
master   rendered-master-27bede19f36ea39ad1cbbed327b73cf1   True      False      False      3              3                   3                     0                      20d
worker   rendered-worker-794f2fc90cae4c5192cbb909b181a419   False     True       True       11             0                   0                     11                     20d
[root@ce0128-ccmmt-master-0 ~]#
```
* UPDATED
  * True: configuration update done for all nodes
  * False: configuration update not done for all nodes
* UPDATING
  * True: Update in progress
  * False: update is done
* DEGRADED
  * True: some node degraded (DEGRADEDMACHINECOUNT)
  * False: no node degraded

# Monitoring MCO Update
```bash
oc logs -l k8s-app=machine-config-controller -n openshift-machine-config-operator
```
In the logs from this pod, you'll see nodes in the cluster sequentially being cordoned (made schedulable=False) and then rebooted. Whilst rebooting and applying the new configuration, they will be seen as NotReady status in oc get nodes).

```bash
oc get nodes
```

# Troubleshotting Degraded Node
https://purplecarrot.co.uk/post/2021-12-19-machineconfigoperator/#forcing-a-node-to-use-a-specific-machineconfig
https://access.redhat.com/articles/4550741

## How to check node degrade status
```bash
[root@ce0128-ccmmt-master-0 ~]#  for node in $(oc get nodes -o name | awk -F'/' '{ print $2 }');do echo "-------------------- $node ------------------"; oc describe node $node | grep machineconfiguration.openshift.io/state; done
-------------------- ce0128-ccmmt-master-0 ------------------
                    machineconfiguration.openshift.io/state: Done
-------------------- ce0128-ccmmt-master-1 ------------------
                    machineconfiguration.openshift.io/state: Done
-------------------- ce0128-ccmmt-master-2 ------------------
                    machineconfiguration.openshift.io/state: Done
-------------------- ce0128-ccmmt-worker-0-4vj2q ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-5hrt7 ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-djvff ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-kbzc6 ------------------
                    machineconfiguration.openshift.io/state: Done
-------------------- ce0128-ccmmt-worker-0-kcqd8 ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-rcmqd ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-rvwxf ------------------
                    machineconfiguration.openshift.io/state: Done
-------------------- ce0128-ccmmt-worker-0-t4lbk ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-t7qd9 ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-v26s9 ------------------
                    machineconfiguration.openshift.io/state: Degraded
-------------------- ce0128-ccmmt-worker-0-vcbrm ------------------
                    machineconfiguration.openshift.io/state: Degraded
[root@ce0128-ccmmt-master-0 ~]#

* to check node degrade reason
```bash
oc describe node/ci-ln-j4h8nkb-72292-pxqxz-worker-a-fjks4
```

```
https://purplecarrot.co.uk/post/2021-12-19-machineconfigoperator/#forcing-a-node-to-use-a-specific-machineconfig
## Unexpected on-disk state - content mismatch for file
If the files on a node's disk that are under control of the MachineConfig don't match the contents of those same files as specified in that MachineConfig (ie the MachineConfig specified in the node's **machineconfiguration.openshift.io/currentConfig annotation**), then the machine-config-daemon will refuse to apply the update and this will put the MachineConfigPool into a degraded state.

```bash
oc get node -o yaml
```
```yaml
    machineconfiguration.openshift.io/controlPlaneTopology: HighlyAvailable
    machineconfiguration.openshift.io/currentConfig: rendered-worker-794f2fc90cae4c5192cbb909b181a419
    machineconfiguration.openshift.io/desiredConfig: rendered-worker-794f2fc90cae4c5192cbb909b181a419
    machineconfiguration.openshift.io/desiredDrain: uncordon-rendered-worker-794f2fc90cae4c5192cbb909b181a419
    machineconfiguration.openshift.io/lastAppliedDrain: uncordon-rendered-worker-794f2fc90cae4c5192cbb909b181a419
    machineconfiguration.openshift.io/lastSyncedControllerConfigResourceVersion: "12747243"
    machineconfiguration.openshift.io/reason: ""
    machineconfiguration.openshift.io/state: Done
```
* TO get current MC of one node
```bash
oc get node -o jsonpath="{.items[?(@.metadata.name=='ce0128-ccmmt-worker-0-rvwxf')].metadata.annotations['machineconfiguration\.openshift\.io/currentConfig']}"
```
* To get config file content

```bash
oc get mc rendered-worker-794f2fc90cae4c5192cbb909b181a419 -o jsonpath="{.spec.config.storage.files[?(@.path=='/etc/containers/registries.conf')].contents.source}" > a.yaml
```
```bash
[root@ce0128-ccmmt-master-0 ~]# cat a.yaml
data:text/plain;charset=utf-8;base64,dW5xdWFsaWZpZWQtc2VhcmNoLXJlZ2lzdHJpZXMgPSBbInJlZ2lzdHJ5LmFjY2Vzcy5yZWRoYXQuY29tIiwgImRvY2tlci5pbyJdCnNob3J0LW5hbWUtbW9kZSA9ICIiCgpbW3JlZ2lzdHJ5XV0KICBwcmVmaXggPSAiIgogIGxvY2F0aW9uID0gInF1YXkuaW8vb3BlbnNoaWZ0LXJlbGVhc2UtZGV2L29jcC1yZWxlYXNlIgoKICBbW3JlZ2lzdHJ5Lm1pcnJvcl1dCiAgICBsb2NhdGlvbiA9ICJkY2hhcmJvci50cmUubnNuLXJkbmV0Lm5ldDo0NDMvb2NwLzQuMTQuMCIKICAgIHB1bGwtZnJvbS1taXJyb3IgPSAiZGlnZXN0LW9ubHkiCgpbW3JlZ2lzdHJ5XV0KICBwcmVmaXggPSAiIgogIGxvY2F0aW9uID0gInF1YXkuaW8vb3BlbnNoaWZ0LXJlbGVhc2UtZGV2L29jcC1yZWxlYXNlLWRldi9vY3AtdjQuMC1hcnQtZGV2IgoKICBbW3JlZ2lzdHJ5Lm1pcnJvcl1dCiAgICBsb2NhdGlvbiA9ICJkY2hhcmJvci50cmUubnNuLXJkbmV0Lm5ldDo0NDMvb2NwLzQuMTQuMCIKICAgIHB1bGwtZnJvbS1taXJyb3IgPSAiZGlnZXN0LW9ubHkiCg==
[root@ce0128-ccmmt-master-0 ~]
```
copy base64 block to b.txt and decode it
```bash
[root@ce0128-ccmmt-master-0 ~]# base64 -d b.txt
unqualified-search-registries = ["registry.access.redhat.com", "docker.io"]
short-name-mode = ""

[[registry]]
  prefix = ""
  location = "quay.io/openshift-release-dev/ocp-release"

  [[registry.mirror]]
    location = "dcharbor.tre.nsn-rdnet.net:443/ocp/4.14.0"
    pull-from-mirror = "digest-only"

[[registry]]
  prefix = ""
  location = "quay.io/openshift-release-dev/ocp-release-dev/ocp-v4.0-art-dev"

  [[registry.mirror]]
    location = "dcharbor.tre.nsn-rdnet.net:443/ocp/4.14.0"
    pull-from-mirror = "digest-only"
[root@ce0128-ccmmt-master-0 ~]#
```

after changed content, daemon log:
```bash
I1228 03:22:32.207198    4644 daemon.go:670] Transitioned from state: Degraded -> Done
I1228 03:22:32.207293    4644 daemon.go:673] Transitioned from degraded/unreconcilable reason unexpected on-disk state validating against rendered-worker-794f2fc90cae4c5192cbb909b181a419: content mismatch for file "/etc/containers/registries.conf" ->
```

# How to force node use specific MC
update node annotations:
* machineconfiguration.openshift.io/currentConfig
* machineconfiguration.openshift.io/desiredConfig
* if needed, go to that node and then: touch /run/machine-config-daemon-force and then remove
```bash
oc edit node ce0128-ccmmt-worker-0-kbzc6

```

# CRD managed by MCC
* MachineConfig
* KubeletConfig
* ContainerRuntimeConfig

```bash
bash-4.4$ ls *crd*
0000_80_machine-config-operator_01_containerruntimeconfig.crd.yaml  0000_80_machine-config-operator_01_machineconfig.crd.yaml
0000_80_machine-config-operator_01_kubeletconfig.crd.yaml           0000_80_machine-config-operator_01_machineconfigpool.crd.yaml
bash-4.4$

```

# KubeletConfig
As needed, create **multiple KubeletConfig** CRs with a limit of 10 per cluster. For the **first KubeletConfig CR**, the Machine Config Operator (MCO) creates **a machine config appended with kubelet**. With each subsequent CR, the controller creates another kubelet machine config with a numeric suffix. For example, if you have a kubelet machine config with a -2 suffix, the next kubelet machine config is appended with -3

```yaml
[root@ce0128-ccmmt-master-0 ~]# oc get kubeletconfig custom-kubelet -o yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  annotations:
    machineconfiguration.openshift.io/mc-name-suffix: ""
  creationTimestamp: "2023-12-11T05:35:15Z"
  finalizers:
  - 99-worker-generated-kubelet
  generation: 1
  name: custom-kubelet
  resourceVersion: "16641863"
  uid: 5248c078-ebc1-468e-9788-52496215dbe4
spec:
  kubeletConfig:
    allowedUnsafeSysctls:
    - net.sctp.rcvbuf_policy
    - net.sctp.sndbuf_policy
    - net.sctp.sack_timeout
    - net.sctp.auth_enable
  machineConfigPoolSelector:
    matchLabels:
      custom-kubelet: sysctl
```

* ContainerRuntimeConfig
 Using a ContainerRuntimeConfig custom resource (CR), you set the configuration values and add a label to match the MCP. The MCO then rebuilds the crio.conf and storage.conf configuration files on the associated nodes with the updated values.

```yaml
[root@ce0128-ccmmt-master-0 ~]# oc get mcp worker -o yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  creationTimestamp: "2023-12-07T06:06:01Z"
  generation: 14
  labels:
    custom-kubelet: sysctl
    machineconfiguration.openshift.io/mco-built-in: ""
    pools.operator.machineconfiguration.openshift.io/worker: ""
  name: worker
  resourceVersion: "17199999"
  uid: c9da545e-23bf-486d-97bd-d68db1a8edac
spec:
  configuration:
    name: rendered-worker-2193e0af240e8e878671a2811b51ad41
    source:
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 00-worker
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 01-worker-container-runtime
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 01-worker-kubelet
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 97-worker-generated-kubelet
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 98-worker-generated-kubelet
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 99-worker-generated-kubelet
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 99-worker-generated-registries
    - apiVersion: machineconfiguration.openshift.io/v1
      kind: MachineConfig
      name: 99-worker-ssh
  machineConfigSelector:
    matchLabels:
      machineconfiguration.openshift.io/role: worker
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/worker: ""

```
# Machine APIs
## ContainerRuntimeConfig
* ContainerRuntimeConfig
  defines the tuneables of the container runtime
* machineConfigPoolSelector
  A label selector is a label query over a set of resources. The result of matchLabels and matchExpressions are ANDed. An empty label selector matches all objects. A null label selector matches no objects
## KubeletConfig
## MachineConfigPoolSpec
* configuraiton
  The targeted MachineConfig object for the machine config pool.
* machineConfigSelector
* maxUnavailable
  maxUnavailable defines either an integer number or percentage of nodes in the corresponding pool that can go Unavailable during an update
* nodeSelector
  nodeSelector specifies a label selector for Machines
* paused
  paused specifies whether or not changes to this machine config pool should be stopped. This includes generating new desiredMachineConfig and update of machines.

# MachineConfig
Once you create a MachineConfig,  the controller will generate a new "rendered" version that will be used as a target.

Users will **NOT** be allowed to change the MachineConfig object defined by openshift. Although, users will create new MachineConfig objects for their customization. Therefore the MachineConfig object used by the in-cluster Ignition server and daemon running on the machines has to be **a merged version**.

## Final Rendered MachineConfig object
MachineConfig objects can be created by both the OpenShift platform and users to define machine configurations. There is a **final "rendered"** MachineConfig object (prefixed with **rendered-**) that is the **union of its inputs**.

The rendered MachineConfig object contains **merged spec** of all the different MachineConfig objects that are valid for the machine.

To ensure the configuration does not change unexpectedly between usage, all remote content referenced in the ignition config is retrieved and embedded into the merged MachineConfig at the time of generation.

## MachineConfigController
* Coordinate upgrade of machines to desired configurations defined by a MachineConfig object.
* Provide options to control upgrade for sets of machines individually.

## TemplateController
responsible for generating the MachineConfigs for pre-defined roles of machines from internal templates based on cluster configuration.

/etc/mcc/templates
```bash
NAME                                               GENERATEDBYCONTROLLER                      IGNITIONVERSION   AGE
00-master                                          5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
00-worker                                          5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-master-container-runtime                        5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-master-kubelet                                  5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-worker-container-runtime                        5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-worker-kubelet                                  5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
```

* The TemplateController constantly reconciles the MachineConfig objects in the cluster to match its internal state (which is essentially: baked-in templates + controllerconfig). The TemplateController will overwrite any user changes of its owned objects.

* TemplateController **watches** changes to the controllerconfig to generate OpenShift-owned MachineConfig objects.
```bash
[root@ce0128-ccmmt-master-0 ~]# oc get controllerconfigs.machineconfiguration.openshift.io -A
NAME                        AGE
machine-config-controller   21d
[root@ce0128-ccmmt-master-0 ~]#

```
```bash
[root@ce0128-ccmmt-master-0 ~]# grep path worker.yaml  | grep -v source
        path: /usr/local/bin/nm-clean-initrd-state.sh
        path: /etc/NetworkManager/conf.d/01-ipv6.conf
        path: /etc/NetworkManager/conf.d/20-keyfiles.conf
        path: /etc/NetworkManager/conf.d/99-vsphere.conf
        path: /etc/NetworkManager/dispatcher.d/30-resolv-prepender
        path: /etc/audit/rules.d/mco-audit-quiet-containers.rules
        path: /etc/keepalived/monitor.conf
        path: /etc/tmpfiles.d/cleanup-cni.conf
        path: /usr/local/bin/configure-ip-forwarding.sh
        path: /usr/local/bin/configure-ovs.sh
        path: /etc/containers/storage.conf
        path: /etc/kubernetes/manifests/coredns.yaml
        path: /etc/mco/proxy.env
        path: /etc/systemd/system.conf.d/10-default-env-godebug.conf
        path: /etc/mco/internal-registry-pull-secret.json
        path: /etc/modules-load.d/iptables.conf
        path: /etc/kubernetes/manifests/keepalived.yaml
        path: /etc/node-sizing-enabled.env
        path: /usr/local/sbin/dynamic-system-reserved-calc.sh
        path: /etc/systemd/system.conf.d/kubelet-cgroups.conf
        path: /etc/systemd/system/kubelet.service.d/20-logging.conf
        path: /etc/NetworkManager/conf.d/sdn.conf
        path: /etc/NetworkManager/dispatcher.d/pre-up.d/10-ofport-request.sh
        path: /var/lib/kubelet/config.json
        path: /usr/local/bin/resolv-prepender.sh
        path: /etc/kubernetes/ca.crt
        path: /etc/sysctl.d/arp.conf
        path: /etc/sysctl.d/inotify.conf
        path: /etc/sysctl.d/enable-userfaultfd.conf
        path: /etc/sysctl.d/vm-max-map.conf
        path: /usr/local/bin/mco-hostname
        path: /etc/kubernetes/kubelet-plugins/volume/exec/.dummy
        path: /etc/NetworkManager/dispatcher.d/99-vsphere-disable-tx-udp-tnl
        path: /usr/local/bin/vsphere-hostname.sh
[root@ce0128-ccmmt-master-0 ~]#

```

* TemplateController adds OwnerReference or similar annotations on its objects to declare ownership

## UpdateController
responsible for upgrading machines to desired MachineConfig by coordinating with a daemon running on each machine.

The UpdateController coordinates upgrade for machines in a MachineConfigPool. UpdateController uses annotations on node objects to coordinate with the MachineConfigDaemon running on each machine to upgrade each machine to the desired Machine Configuration.

## RenderController
responsible for discovering MachineConfigs for a Pool of Machines and generating the static MachineConfig

The RenderController generates the desired MachineConfig object based on the **MachineConfigSelector** defined in MachineConfigPool.

* RenderController **watches for changes on MachineConfigPool** object to find all the MachineConfig objects using MachineConfigSelector and updating the CurrentMachineConfig with the generated MachineConfig.
* RenderController **watches for changes on all the MachineConfig** objects and syncs all the MachineConfigPool objects with new CurrentMachineConfig.

## KubeletConfigController
responsible for wrapping custom Kubelet configurations within a CRD

## MachineSets vs MachineConfigPool
* MachineSets describe nodes with respect to cloud / machine provider. MachineConfigPool allows MachineConfigController components to **define and provide** status of machines in context of upgrades.
* MachineConfigPool also allows users to configure how upgrades are rolled out to the machines in a pool.
* NodeSelector can be replaced with reference to MachineSet.

# MachineConfigDaemon
* Apply new machine configuration during update.
* Validate and verify machine's state to the requested machine configuration.


# MachineConfigPool

https://www.redhat.com/en/blog/openshift-container-platform-4-how-does-machine-config-pool-work

The Render controller in the Machine Config Controller monitors the Machine Config Pool and generates static machine config objects named rendered-master-XXXX and rendered-worker-xxx. These objects can include multiple machine configs. The Render controller then checks whether the nodes in the pool have applied the latest rendered-xxxx machine config. If the machine config pool changes, then the render controller creates a new rendered-xxx and applies it.

When create new MC named 99-worker-test, new rendered mc will be created, and then mcp worker will be updated automatically with newly added MC 

 ```bash
 99-worker-test                                                                                3.2.0             7m53s
rendered-master-27bede19f36ea39ad1cbbed327b73cf1   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             3d
rendered-master-31569da0b21025df6f9ae037277b35aa   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
rendered-master-8116c36e31c74cc6fd2ab9c7ff692d2a   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
rendered-master-8437987e9dfda4e654959f3dcae32213   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
rendered-worker-2193e0af240e8e878671a2811b51ad41   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             3d
rendered-worker-7793be48dcae1be22b33ce1250d2b1da   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
rendered-worker-794f2fc90cae4c5192cbb909b181a419   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
rendered-worker-86bb5e9bc13adca7b560b205333dff94   5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             7m48s

 ```

here below CONFIG column and status.configuration.name means CurrentMachineConfig.

 ```bash
 [root@ce0128-ccmmt-master-0 ~]# oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
master   rendered-master-27bede19f36ea39ad1cbbed327b73cf1   True      False      False      3              3                   3                     0                      21d
worker   rendered-worker-794f2fc90cae4c5192cbb909b181a419   False     True       True       11             0                   0                     9                      21d
 ```
```yaml
status:
   ...
   configuration:
    name: rendered-worker-794f2fc90cae4c5192cbb909b181a419
```

The below rendered MC is newly created and targetMachineConfig

 ```yaml
 spec:
  configuration:
    name: rendered-worker-86bb5e9bc13adca7b560b205333dff94

 ```

 When all node Updated, then currentMachineConfig will be changed to targetMachineConfig
 