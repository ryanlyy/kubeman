WireGuard used in Calico
-----------------------

# How to setup WireGaurd Communication
* host 1
  ```bash
    apt-get install wireguard
    apt-get install wireguard-dkms
    modprobe wireguard
    lsmod | grep wireg
    modinfo wireguard
    wg genkey > private
    ip link add wg0 type wireguard
    ip addr add 10.0.0.1/24 dev wg0
    wg set wg0 private-key ./private 
    ip link set wg0 up
    ip -d addr
  ```
  ```bash
    root@eksa-1:~/wg# wg
    interface: wg0
    public key: A6wuE9iCAy84+iPqK7F2jDd6QvZ0PVfqhm2l8gVH8xc=
    private key: (hidden)
    listening port: 53257

    peer: t35/blZDxcKoDPA/fOxVM6ZXNUWRtsVtWPCZvcfTCGY=
    endpoint: 10.67.26.198:45392
    allowed ips: 10.0.0.2/32
    latest handshake: 1 minute, 30 seconds ago
    transfer: 66.00 KiB received, 65.57 KiB sent
    root@eksa-1:~/wg# 
    root@eksa-1:~/wg# ip addr show eno1
    2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
        link/ether 2c:59:e5:37:cc:f8 brd ff:ff:ff:ff:ff:ff
        inet 10.67.26.196/26 brd 10.67.26.255 scope global eno1
        valid_lft forever preferred_lft forever
        inet6 fe80::2e59:e5ff:fe37:ccf8/64 scope link 
        valid_lft forever preferred_lft forever
    root@eksa-1:~/wg# 
    wg set wg0 peer t35/blZDxcKoDPA/fOxVM6ZXNUWRtsVtWPCZvcfTCGY= allowed-ips 10.0.0.2/32 endpoint 10.67.26.198:45392
  ```
* host 2
  ```bash
    apt-get install wireguard
    apt-get install wireguard-dkms
    lsmod | grep wireg
    modprobe wireguard
    lsmod | grep wireg
    modinfo wireguard
    wg genkey > private
    ip link add wg0 type wireguard
    ip addr add 10.0.0.2/24 dev wg0
    wg set wg0 private-key ./private 
    ip link set wg0 up
    ip -d addr
  ```
  ```bash
    root@eksa-2:~/wg# wg
    interface: wg0
    public key: t35/blZDxcKoDPA/fOxVM6ZXNUWRtsVtWPCZvcfTCGY=
    private key: (hidden)
    listening port: 45392

    peer: A6wuE9iCAy84+iPqK7F2jDd6QvZ0PVfqhm2l8gVH8xc=
    endpoint: 10.67.26.196:53257
    allowed ips: 10.0.0.1/32
    latest handshake: 3 minutes, 31 seconds ago
    transfer: 65.57 KiB received, 66.00 KiB sent
    root@eksa-2:~/wg# 
    root@eksa-2:~/wg# ip addr show eno1
    2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
        link/ether 3c:d9:2b:f6:4a:c0 brd ff:ff:ff:ff:ff:ff
        inet 10.67.26.198/26 brd 10.67.26.255 scope global eno1
        valid_lft forever preferred_lft forever
        inet6 fe80::3ed9:2bff:fef6:4ac0/64 scope link 
        valid_lft forever preferred_lft forever
    root@eksa-2:~/wg# 
    wg set wg0 peer A6wuE9iCAy84+iPqK7F2jDd6QvZ0PVfqhm2l8gVH8xc= allowed-ips 10.0.0.1/32 endpoint 10.67.26.196:53257
  ```