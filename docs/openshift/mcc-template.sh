[root@ce0128-ccmmt-master-0 ~]# oc get mc | grep -v generated | grep -v render
NAME                                               GENERATEDBYCONTROLLER                      IGNITIONVERSION   AGE
00-master                                          5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
00-worker                                          5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-master-container-runtime                        5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-master-kubelet                                  5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-worker-container-runtime                        5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
01-worker-kubelet                                  5ac7b4ae0bca76358e4d40f546306775a8e0ea2c   3.4.0             21d
99-master-ssh                                                                                 3.2.0             21d
99-worker-ssh                                                                                 3.2.0             21d
[root@ce0128-ccmmt-master-0 ~]#


bash-4.4$ pwd
/etc/mcc/templates
bash-4.4$ find . -type f
./common/_base/files/NetworkManager-clean-initrd-state.yaml
./common/_base/files/NetworkManager-ipv6.conf.yaml
./common/_base/files/NetworkManager-keyfiles.yaml
./common/_base/files/audit-quiet-containers.yaml
./common/_base/files/cleanup-cni-conf.yaml
./common/_base/files/configure-ovs-network.yaml
./common/_base/files/container-storage.yaml
./common/_base/files/etc-mco-proxy.yaml
./common/_base/files/etc-systemd-system.conf.d-10-default-env-godebug.conf.yaml
./common/_base/files/internal-registry-pull-secret.yaml
./common/_base/files/iptables-modules.yaml
./common/_base/files/kubelet-auto-node-sizing-enabled.yaml
./common/_base/files/kubelet-auto-sizing.yaml
./common/_base/files/kubelet-log-level.yaml
./common/_base/files/mtu-migration.yaml
./common/_base/files/nm-ignore-sdn.yaml
./common/_base/files/ofport-request.yaml
./common/_base/files/pull-secret.yaml
./common/_base/files/root-ca.yaml
./common/_base/files/sysctl-arp.conf.yaml
./common/_base/files/sysctl-forward-conf.yaml
./common/_base/files/sysctl-inotify.conf.yaml
./common/_base/files/sysctl-userfaultfd.yaml
./common/_base/files/sysctl-vm-max-map.conf.yaml
./common/_base/files/usr-local-bin-mco-hostname.yaml
./common/_base/files/volume-plugins.yaml
./common/_base/files/vsphere-disable-vmxnet3v4-features.yaml
./common/_base/units/NetworkManager-clean-initrd-state.yaml
./common/_base/units/crio.service-kubens.yaml
./common/_base/units/crio.service-proxy.yaml
./common/_base/units/crio.service-socket.yaml
./common/_base/units/crio.service.yaml
./common/_base/units/docker.socket.yaml
./common/_base/units/kubelet-auto-node-size.service.yaml
./common/_base/units/kubelet.service-kubens.yaml
./common/_base/units/kubelet.service-proxy.yaml
./common/_base/units/kubelet.service.yaml
./common/_base/units/kubens.service.yaml
./common/_base/units/machine-config-daemon-firstboot.service.yaml
./common/_base/units/machine-config-daemon-pull.service.yaml
./common/_base/units/mtu-migration.service.yaml
./common/_base/units/node-valid-hostname.service.yaml
./common/_base/units/nodeip-configuration.service.yaml
./common/_base/units/openvswitch.service.yaml
./common/_base/units/ovs-configuration.service.yaml
./common/_base/units/ovs-vswitchd.service.yaml
./common/_base/units/ovsdb-server.service.yaml
./common/_base/units/pivot.service.yaml
./common/_base/units/rpm-ostreed-proxy.service.yaml
./common/_base/units/zincati.service.yaml
./common/alibabacloud/OWNERS
./common/alibabacloud/files/usr-local-bin-alibaba-kubelet-nodename.yaml
./common/alibabacloud/files/usr-local-lib-systemd-system-generators-alibaba-kubelet-extra-env-generator.sh.yaml
./common/alibabacloud/units/alibaba-kubelet-nodename.service.yaml
./common/aws/files/usr-local-bin-aws-kubelet-nodename.yaml
./common/aws/files/usr-local-bin-aws-kubelet-providerid.yaml
./common/aws/units/aws-kubelet-nodename.service.yaml
./common/aws/units/aws-kubelet-providerid.service.yaml
./common/baremetal/OWNERS
./common/baremetal/files/NetworkManager-clean-initrd-state-opt-in.yaml
./common/baremetal/files/NetworkManager-static-dhcp.yaml
./common/baremetal/files/NetworkManager-static-dhcpv6.yaml
./common/gcp/files/etc-networkmanager-conf.d-hostname.yaml
./common/gcp/units/gcp-hostname.service.yaml
./common/kubevirt/OWNERS
./common/kubevirt/files/001-nmstate-disable-ipv6-autoconf.yaml
./common/kubevirt/files/002-nmstate-arp-proxy-ipv6-gw.yaml
./common/on-prem/OWNERS
./common/on-prem/files/NetworkManager-onprem.conf.yaml
./common/on-prem/files/NetworkManager-resolv-prepender.yaml
./common/on-prem/files/baremetal-keepalived-flip-mode.yaml
./common/on-prem/files/configure-ip-forwarding.yaml
./common/on-prem/files/coredns-corefile.yaml
./common/on-prem/files/coredns.yaml
./common/on-prem/files/keepalived-script-default-ingress.yaml
./common/on-prem/files/keepalived.yaml
./common/on-prem/files/resolv-prepender.yaml
./common/on-prem/units/kubelet.service-wait-resolv.yaml
./common/on-prem/units/nodeip-configuration.service.yaml
./common/on-prem/units/on-prem-resolv-prepender.service.yaml
./common/openstack/OWNERS
./common/openstack/files/ipv6-config.yaml
./common/openstack/files/usr-local-bin-openstack-afterburn-hostname.yaml
./common/openstack/files/usr-local-bin-openstack-kubelet-nodename.yaml
./common/openstack/units/afterburn-hostname.service.yaml
./common/openstack/units/openstack-kubelet-nodename.service.yaml
./common/ovirt/OWNERS
./common/powervs/OWNERS
./common/powervs/units/afterburn-hostname.service.yaml
./common/sno/OWNERS
./common/sno/files/sno-dnsmasq.conf.yaml
./common/vsphere/OWNERS
./common/vsphere/files/vsphere-hostname.yaml
./common/vsphere/units/nodeip-configuration-vsphere-upi.service.yaml
./common/vsphere/units/vsphere-hostname.service.yaml
./master/00-master/_base/files/apiserver-url-env.yaml
./master/00-master/_base/files/kubelet-cgroups.yaml
./master/00-master/_base/files/usr-local-bin-openshift-kubeconfig-gen.yaml
./master/00-master/_base/units/rpm-ostreed.service.yaml
./master/00-master/alibabacloud/files/etc-kubernetes-manifests-apiserver-watcher.yaml
./master/00-master/alibabacloud/files/opt-libexec-openshift-alibabacloud-routes-sh.yaml
./master/00-master/alibabacloud/units/openshift-alibabacloud-routes.path.yaml
./master/00-master/alibabacloud/units/openshift-alibabacloud-routes.service.yaml
./master/00-master/azure/files/etc-kubernetes-manifests-apiserver-watcher.yaml
./master/00-master/azure/files/opt-libexec-openshift-azure-routes-sh.yaml
./master/00-master/azure/units/openshift-azure-routes.path.yaml
./master/00-master/azure/units/openshift-azure-routes.service.yaml
./master/00-master/gcp/files/etc-kubernetes-manifests-apiserver-watcher.yaml
./master/00-master/gcp/files/opt-libexec-openshift-gcp-routes-sh.yaml
./master/00-master/gcp/units/gcp-routes.service.yaml
./master/00-master/gcp/units/openshift-gcp-routes.service.yaml
./master/00-master/on-prem/OWNERS
./master/00-master/on-prem/files/haproxy-haproxy.yaml
./master/00-master/on-prem/files/haproxy.yaml
./master/00-master/on-prem/files/keepalived-keepalived.yaml
./master/00-master/on-prem/files/keepalived-script-both.yaml
./master/00-master/on-prem/files/keepalived-script.yaml
./master/00-master/openstack/OWNERS
./master/00-master/sno/OWNERS
./master/00-master/sno/files/sno-forcedns-fix.yaml
./master/01-master-container-runtime/OWNERS
./master/01-master-container-runtime/_base/files/container-registries.yaml
./master/01-master-container-runtime/_base/files/crio.yaml
./master/01-master-container-runtime/_base/files/policy.yaml
./master/01-master-container-runtime/openstack/OWNERS
./master/01-master-kubelet/OWNERS
./master/01-master-kubelet/_base/files/cloudconfig.yaml
./master/01-master-kubelet/_base/files/kubelet.yaml
./master/01-master-kubelet/_base/files/kubenswrapper.yaml
./master/01-master-kubelet/_base/units/kubelet.service.yaml
./master/01-master-kubelet/alibabacloud/units/kubelet.service.yaml
./master/01-master-kubelet/on-prem/units/kubelet.service.yaml
./master/01-master-kubelet/openstack/OWNERS
./worker/00-worker/_base/files/kubelet-cgroups.yaml
./worker/00-worker/on-prem/OWNERS
./worker/00-worker/on-prem/files/keepalived-keepalived.yaml
./worker/00-worker/openstack/OWNERS
./worker/01-worker-container-runtime/OWNERS
./worker/01-worker-container-runtime/_base/files/container-registries.yaml
./worker/01-worker-container-runtime/_base/files/crio.yaml
./worker/01-worker-container-runtime/_base/files/policy.yaml
./worker/01-worker-container-runtime/openstack/OWNERS
./worker/01-worker-kubelet/OWNERS
./worker/01-worker-kubelet/_base/files/cloudconfig.yaml
./worker/01-worker-kubelet/_base/files/kubelet.yaml
./worker/01-worker-kubelet/_base/files/kubenswrapper.yaml
./worker/01-worker-kubelet/_base/units/kubelet.service.yaml
./worker/01-worker-kubelet/alibabacloud/units/kubelet.service.yaml
./worker/01-worker-kubelet/on-prem/units/kubelet.service.yaml
./worker/01-worker-kubelet/openstack/OWNERS
bash-4.4$
