tips
------------


# must-gater usage
```bash
    [root@ce0128-ccmmt-master-0 ryliu]# export HTTP_PROXY=http://10.158.100.2:8080
    [root@ce0128-ccmmt-master-0 ryliu]# export HTTPS_PROXY=http://10.158.100.2:8080
    [root@ce0128-ccmmt-master-0 ryliu]# oc adm must-gather
    [must-gather      ] OUT Using must-gather plug-in image: quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:474d6aba2e2084a95732de1853e5c87b31aa101afb554798ebf97a960bebc293
    When opening a support case, bugzilla, or issue please include the following summary data along with any other requested information:
    ClusterID: 3cdb6dcc-6e8f-46a4-a2ac-4bf871f6264c
    ClusterVersion: Stable at "4.14.0"
    ClusterOperators:
            All healthy and stable
    
    
    [must-gather      ] OUT namespace/openshift-must-gather-chsdv created
    [must-gather      ] OUT clusterrolebinding.rbac.authorization.k8s.io/must-gather-v6nld created
    [must-gather      ] OUT pod for plug-in image quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:474d6aba2e2084a95732de1853e5c87b31aa101afb554798ebf97a960bebc293 created
    [must-gather-sqvsf] POD 2024-01-18T06:36:51.246510464Z Gathering data for ns/openshift-cluster-version...
    [must-gather-sqvsf] POD 2024-01-18T06:36:53.002393236Z Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
    [must-gather-sqvsf] POD 2024-01-18T06:36:53.187784022Z Gathering data for ns/default...
    ....
```

# CPU PerformanceProfile
```bash
    [root@ce0128-ccmmt-master-0 must-gather]# podman run --entrypoint performance-profile-creator -v /root/must-gather/must-gather.local.6443320572621405887:/must-gather:z registry.redhat.io/openshift4/ose-cluster-node-tuning-operator:v4.14 --mcp-name=worker --reserved-cpu-count=4 --rt-kernel=true --split-reserved-cpus-across-numa=false --must-gather-dir-path /must-gather --power-consumption-mode=ultra-low-latency --offlined-cpu-count=6 > my-performance-profile.yaml        
    level=info msg="Nodes targetted by worker MCP are: [ce0128-ccmmt-worker-0-4vj2q ce0128-ccmmt-worker-0-5hrt7 ce0128-ccmmt-worker-0-djvff ce0128-ccmmt-worker-0-kbzc6 ce0128-ccmmt-worker-0-kcqd8 ce0128-ccmmt-worker-0-rcmqd ce0128-ccmmt-worker-0-rvwxf ce0128-ccmmt-worker-0-t4lbk ce0128-ccmmt-worker-0-t7qd9 ce0128-ccmmt-worker-0-v26s9 ce0128-ccmmt-worker-0-vcbrm]"
    level=info msg="NUMA cell(s): 1"
    level=info msg="NUMA cell 0 : [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]"
    level=info msg="CPU(s): 16"
    level=info msg="4 reserved CPUs allocated: 0-3 "
    level=info msg="6 isolated CPUs allocated: 10-15"
    level=info msg="Additional Kernel Args based on configuration: []"
    [root@ce0128-ccmmt-master-0 must-gather]# ls
    must-gather.local.6443320572621405887  my-performance-profile.yaml
    [root@ce0128-ccmmt-master-0 must-gather]# ls -lstr
    total 4
    0 drwxr-xr-x. 3 root root 174 Jan 17 06:14 must-gather.local.6443320572621405887
    4 -rw-r--r--. 1 root root 442 Jan 18 06:56 my-performance-profile.yaml
    [root@ce0128-ccmmt-master-0 must-gather]# cat my-performance-profile.yaml
    ---
    apiVersion: performance.openshift.io/v2
    kind: PerformanceProfile
    metadata:
    name: performance
    spec:
    cpu:
        isolated: 10-15
        offlined: 4-9
        reserved: 0-3
    machineConfigPoolSelector:
        worker: ""
    nodeSelector:
        node-role.kubernetes.io/worker: ""
    numa:
        topologyPolicy: restricted
    realTimeKernel:
        enabled: true
    workloadHints:
        highPowerConsumption: true
        perPodPowerManagement: false
        realTime: true
    [root@ce0128-ccmmt-master-0 must-gather]# date
    Thu Jan 18 06:57:09 UTC 2024
    [root@ce0128-ccmmt-master-0 must-gather]#
```
# sos reports
```bash
    [root@ce0128-ccmmt-master-0 ~]# oc debug node/ce0128-ccmmt-worker-0-5hrt7
    Starting pod/ce0128-ccmmt-worker-0-5hrt7-debug-ncw7c ...
    To use host binaries, run `chroot /host`
    Pod IP: 100.74.47.228
    If you don't see a command prompt, try pressing enter.
    sh-4.4# export HTTPS_PROXY=http://10.158.100.2:8080
    sh-4.4# export HTTP_PROXY=http://10.158.100.2:8080
    sh-4.4# chroot /host
    sh-5.1# toolbox
    Trying to pull registry.redhat.io/rhel9/support-tools:latest...
    Getting image source signatures
    Checking if image destination supports signatures
    Copying blob 36cdb1adff1d done
    Copying blob af8f1220909b done
    Copying config 492f8038f6 done
    Writing manifest to image destination
    Storing signatures
    492f8038f69c995e4521bd8538fce0723ad4e43dd87438c2305050c8e0bcd52f
    Spawning a container 'toolbox-root' with image 'registry.redhat.io/rhel9/support-tools'
    Detected RUN label in the container image. Using that as the default...
    207444121d4594ab9d0a80d7adb66742e312e31c7e22394328138e8f0b1a7931
    toolbox-root
    Container started successfully. To exit, type 'exit'.
    [root@ce0128-ccmmt-worker-0-5hrt7 /]# sos
    usage: sos <component> [options]
    
    Available components:
            report, rep                   Collect files and command output in an archive
            clean, cleaner, mask          Obfuscate sensitive networking information in a report
            help                          Detailed help infomation
            collect, collector            Collect an sos report from multiple nodes simultaneously
```