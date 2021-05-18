Kata Container
---

- [What is Kata-container???](#what-is-kata-container)
- [CRI & Conainerd & Kata Containerd Runtime](#cri--conainerd--kata-containerd-runtime)
  - [runc & kata-container](#runc--kata-container)
- [Kata Container Runtime Installation](#kata-container-runtime-installation)
  - [kubeadm init](#kubeadm-init)
- [Containerd as Runtime Configuration](#containerd-as-runtime-configuration)
  - [proxy](#proxy)
  - [Runtime Plugin](#runtime-plugin)
- [Start Kata Container](#start-kata-container)
  - [Kata-container configuration](#kata-container-configuration)
  - [Containers](#containers)
  - [Host Processes (qemu-kvm)](#host-processes-qemu-kvm)
- [Kubernetes Integration with Kata Container](#kubernetes-integration-with-kata-container)
- [Networking???](#networking)
- [Debugging](#debugging)
- [process in VM???](#process-in-vm)
  

<span style="color:red;font-size:4em;">The speed of containers,  the security of VMs<span>

# What is Kata-container???
Kata Containers is an open source community working to build **a secure container runtime** with lightweight virtual machines that feel and perform like containers, but provide stronger workload isolation using hardware virtualization technology as a second layer of defense

# CRI & Conainerd & Kata Containerd Runtime
![CRI Container Integration with Kata Container Runtime](../pics/kata.JPG)

## runc & kata-container
![Runc & Kata-container](../pics/kata-runc.JPG)

# Kata Container Runtime Installation
```
dnf install -y centos-release-advanced-virtualization
dnf module disable -y virt:rhel
source /etc/os-release
cat <<EOF | sudo -E tee /etc/yum.repos.d/kata-containers.repo
  [kata-containers]
  name=Kata Containers
  baseurl=http://mirror.centos.org/\$contentdir/\$releasever/virt/\$basearch/kata-containers
  enabled=1
  gpgcheck=1
  skip_if_unavailable=1
  EOF
install -y kata-containers
```
## kubeadm init
```
kubeadm init --pod-network-cidr=192.168.0.0/16  --cri-socket=unix:///run/containerd/containerd.sock
```
```
/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.4.1
```

```
[root@foss-ssc-6 crio]# cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.4.1"
[root@foss-ssc-6 crio]#
```

# Containerd as Runtime Configuration
## proxy
```
[Service]
Environment=HTTP_PROXY=http://10.158.100.9:8080
Environment=HTTPS_PROXY=http://10.158.100.9:8080
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
```

## Runtime Plugin
```
#   limitations under the License.

#disabled_plugins = ["cri"]

...


[plugins.cri.containerd]
  no_pivot = false
  [plugins.cri.containerd.runtimes]
    [plugins.cri.containerd.runtimes.runc]
      runtime_type = "io.containerd.runc.v1"
      [plugins.cri.containerd.runtimes.runc.options]
        NoPivotRoot = false
        NoNewKeyring = false
        ShimCgroup = ""
        IoUid = 0
        IoGid = 0
        BinaryName = "runc"
        Root = ""
        CriuPath = ""
        SystemdCgroup = false
    [plugins.cri.containerd.runtimes.kata]
      runtime_type = "io.containerd.kata.v2"
    [plugins.cri.containerd.runtimes.katacli]
      runtime_type = "io.containerd.runc.v1"
      [plugins.cri.containerd.runtimes.katacli.options]
        NoPivotRoot = false
        NoNewKeyring = false
        ShimCgroup = ""
        IoUid = 0
        IoGid = 0
        BinaryName = "/usr/bin/kata-runtime"
        Root = ""
        CriuPath = ""
        SystemdCgroup = false

 # "plugins.cri.containerd.default_runtime" is the runtime to use in containerd.
[plugins.cri.containerd.default_runtime]
  # runtime_type is the runtime type to use in containerd e.g. io.containerd.runtime.v1.linux
  runtime_type = "io.containerd.runtime.v1.linux"

# "plugins.cri.containerd.untrusted_workload_runtime" is a runtime to run untrusted workloads on it.
[plugins.cri.containerd.untrusted_workload_runtime]
  # runtime_type is the runtime type to use in containerd e.g. io.containerd.runtime.v1.linux
  runtime_type = "io.containerd.kata.v2"
  # runtime_engine is the name of the runtime engine used by containerd.
```

# Start Kata Container
```
[root@foss-ssc-6 ~]# ctr run --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/busybox:latest hello sh
/ # ps -ef
PID   USER     TIME  COMMAND
    1 root      0:00 sh
    2 root      0:00 ps -ef
/ #
```

## Kata-container configuration
```
cat /usr/share/kata-containers/defaults/configuration.toml
```
## Containers
```
[root@foss-ssc-6 libexec]# ctr c ls
CONTAINER    IMAGE                               RUNTIME
hello        docker.io/library/busybox:latest    io.containerd.run.kata.v2
[root@foss-ssc-6 libexec]#
```

## Host Processes (qemu-kvm)
```
[root@foss-ssc-6 yum.repos.d]# ps -ef | grep kata
root     1537920 1007772  0 13:32 pts/2    00:00:00 ctr run --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/busybox:latest hello sh

1537941 ?        Sl     0:04 /usr/bin/containerd-shim-kata-v2 -namespace default -address /run/containerd/containerd.sock -publish-binary /usr/bin/containerd -id hello
1537951 ?        Sl     0:00  \_ /usr/libexec/virtiofsd --fd=3 -o source=/run/kata-containers/shared/sandboxes/hello/shared -o cache=auto --syslog -o no_posix_lock -f --thread-pool-size=1
1537961 ?        Sl     0:00      \_ /usr/libexec/virtiofsd --fd=3 -o source=/run/kata-containers/shared/sandboxes/hello/shared -o cache=auto --syslog -o no_posix_lock -f --thread-pool-size=1

root     1537958       1 53 13:32 ?        00:00:10 /usr/libexec/qemu-kvm -name sandbox-hello -uuid 461e04f9-3544-483a-9e0c-57d1d3fb152e -machine q35,accel=kvm,kernel_irqchip -cpu host,pmu=off -qmp unix:/run/vc/vm/hello/qmp.sock,server,nowait -m 2048M,slots=10,maxmem=32938M -device pci-bridge,bus=pcie.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2,romfile= -device virtio-serial-pci,disable-modern=false,id=serial0,romfile= -device virtconsole,chardev=charconsole0,id=console0 -chardev socket,id=charconsole0,path=/run/vc/vm/hello/console.sock,server,nowait -device virtio-scsi-pci,id=scsi0,disable-modern=false,romfile= -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0,romfile= -device vhost-vsock-pci,disable-modern=false,vhostfd=3,id=vsock-1616513657,guest-cid=1616513657,romfile= -chardev socket,id=char-10984ae27fc7ed40,path=/run/vc/vm/hello/vhost-fs.sock -device vhost-user-fs-pci,chardev=char-10984ae27fc7ed40,tag=kataShared,romfile= -rtc base=utc,driftfix=slew,clock=host -global kvm-pit.lost_tick_policy=discard -vga none -no-user-config -nodefaults -nographic --no-reboot -daemonize -object memory-backend-file,id=dimm1,size=2048M,mem-path=/dev/shm,share=on -numa node,memdev=dimm1 -kernel /usr/lib/modules/4.18.0-240.22.1.el8_3.x86_64/vmlinuz -initrd /var/cache/kata-containers/osbuilder-images/4.18.0-240.22.1.el8_3.x86_64/"centos"-kata-4.18.0-240.22.1.el8_3.x86_64.initrd -append tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 quiet panic=1 nr_cpus=16 scsi_mod.scan=none -pidfile /run/vc/vm/hello/pid -smp 1,cores=1,threads=1,sockets=16,maxcpus=16
```


# Kubernetes Integration with Kata Container
```
apiVersion: node.k8s.io/v1  # RuntimeClass is defined in the node.k8s.io API group
kind: RuntimeClass
metadata:
  name: mykata # The name the RuntimeClass will be referenced by
  # RuntimeClass is a non-namespaced resource
handler: kata # The name of the corresponding CRI configuration
```
"kata" in "handler: kata" is same with "kata" of "plugins.cri.containerd.runtimes.kata" in /etc/containerd/config.toml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    io.kubernetes.cri.untrusted-workload: "true"
  name: nginx-deployment-kata
spec:
  selector:
    matchLabels:
      app: nginx-kata
  replicas: 1 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx-kata
    spec:
      runtimeClassName: mykata
      containers:
      - name: nginx-kata
        image: nginx:1.14.2
        ports:
        - containerPort: 8000

```
"runtimeClassName: mykata", here "mykata" is name if RuntimeClass defined above.

```
NAMESPACE         NAME                                     READY   STATUS    RESTARTS   AGE
default           nginx-deployment-66b6c48dd5-z2lz6        1/1     Running   0          24m
default           nginx-deployment-kata-547c444767-lx5dh   2/2     Running   0          3m40s
```

```
[root@foss-ssc-6 crio]# crictl pods
POD ID              CREATED             STATE               NAME                                     NAMESPACE           ATTEMPT             RUNTIME
7ad443e1a4894       12 minutes ago      Ready               nginx-deployment-kata-547c444767-pzjtm   default             0                   kata
868196a98aaab       55 minutes ago      Ready               nginx-deployment-66b6c48dd5-z2lz6        default             0                   (default)

```

# Networking???

here CNI is "bridge"
```
[root@foss-ssc-6 crio]# brctl show
bridge name     bridge id               STP enabled     interfaces
cni0            8000.9615ea61eda7       no
docker0         8000.02426758e8bd       no
mybridge                8000.2af402f81b2e       no              veth32fa0e96
                                                        veth4ae2f351
                                                        vethfecd0aa6
virbr0          8000.525400d4b5fc       yes             virbr0-nic
[root@foss-ssc-6 crio]# kubectl apply -f kata-deployment.yaml
deployment.apps/nginx-deployment-kata created
[root@foss-ssc-6 crio]# brctl show
bridge name     bridge id               STP enabled     interfaces
cni0            8000.9615ea61eda7       no
docker0         8000.02426758e8bd       no
mybridge                8000.2af402f81b2e       no              veth32fa0e96
                                                        veth4ae2f351
                                                        vetha27d5842
                                                        vethfecd0aa6
virbr0          8000.525400d4b5fc       yes             virbr0-nic
[root@foss-ssc-6 crio]#
```

# Debugging

```
kubectl exec -ti nginx-deployment-kata-547c444767-pzjtm -c alpine-kata -- dmesg
cat /usr/share/kata-containers/defaults/configuration.toml
```

# process in VM???