- [Operators categories](#operators-categories)


# Operators categories
* Cluster Operator
    ```bash
        [root@ce0128-ccmmt-master-0 ~]# oc get co
        NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
        authentication                             4.14.0    True        False         False      121m
        baremetal                                  4.14.0    True        False         False      22d
        cloud-controller-manager                   4.14.0    True        False         False      22d
        cloud-credential                           4.14.0    True        False         False      22d
        cluster-autoscaler                         4.14.0    True        False         False      22d
        config-operator                            4.14.0    True        False         False      22d
        console                                    4.14.0    True        False         False      121m
        control-plane-machine-set                  4.14.0    True        False         False      22d
        csi-snapshot-controller                    4.14.0    True        False         False      22d
        dns                                        4.14.0    True        False         False      22d
        etcd                                       4.14.0    True        False         False      22d
        image-registry                             4.14.0    True        False         False      7d22h
        ingress                                    4.14.0    True        False         False      22d
        insights                                   4.14.0    True        False         False      22d
        kube-apiserver                             4.14.0    True        False         False      22d
        kube-controller-manager                    4.14.0    True        False         False      22d
        kube-scheduler                             4.14.0    True        False         False      22d
        kube-storage-version-migrator              4.14.0    True        False         False      3d22h
        machine-api                                4.14.0    True        False         False      22d
        machine-approver                           4.14.0    True        False         False      22d
        machine-config                             4.14.0    True        False         False      22d     
        marketplace                                4.14.0    True        False         False      22d
        monitoring                                 4.14.0    True        False         False      41h
        network                                    4.14.0    True        False         False      22d
        node-tuning                                4.14.0    True        False         False      22d
        openshift-apiserver                        4.14.0    True        False         False      41h
        openshift-controller-manager               4.14.0    True        False         False      22d
        openshift-samples                          4.14.0    True        False         False      22d
        operator-lifecycle-manager                 4.14.0    True        False         False      22d
        operator-lifecycle-manager-catalog         4.14.0    True        False         False      22d
        operator-lifecycle-manager-packageserver   4.14.0    True        False         False      41h
        service-ca                                 4.14.0    True        False         False      22d
        storage                                    4.14.0    True        False         False      41h
        [root@ce0128-ccmmt-master-0 ~]#
    ```
* Add-on Operator
  Operators installed by OLM and OperatorHub

  Default catelog sourece in OperatorHub:
  * Red Hat Operators, 
  * certified Operators, 
  * community Operators
  
* Platform Operator (TP)


```bash
[root@ce0128-ccmmt-master-0 ~]# oc get ns | grep openshift
openshift                                          Active   21d #No Resource in vLAB
openshift-apiserver                                Active   21d
openshift-apiserver-operator                       Active   21d
openshift-authentication                           Active   21d
openshift-authentication-operator                  Active   21d
openshift-cloud-controller-manager                 Active   21d
openshift-cloud-controller-manager-operator        Active   21d
openshift-cloud-credential-operator                Active   21d
openshift-cloud-network-config-controller          Active   21d
openshift-cluster-csi-drivers                      Active   21d
openshift-cluster-machine-approver                 Active   21d
openshift-cluster-node-tuning-operator             Active   21d
openshift-cluster-samples-operator                 Active   21d
openshift-cluster-storage-operator                 Active   21d
openshift-cluster-version                          Active   21d
openshift-config                                   Active   21d
openshift-config-managed                           Active   21d
openshift-config-operator                          Active   21d
openshift-console                                  Active   21d
openshift-console-operator                         Active   21d
openshift-console-user-settings                    Active   21d
openshift-controller-manager                       Active   21d
openshift-controller-manager-operator              Active   21d
openshift-debug-gn2rf                              Active   21d
openshift-debug-mq6cs                              Active   21d
openshift-debug-n9p8s                              Active   21d
openshift-debug-v2z2s                              Active   21d
openshift-debug-v54qh                              Active   21d
openshift-debug-zt7p5                              Active   21d
openshift-dns                                      Active   21d
openshift-dns-operator                             Active   21d
openshift-etcd                                     Active   21d
openshift-etcd-operator                            Active   21d
openshift-host-network                             Active   21d
openshift-image-registry                           Active   21d
openshift-infra                                    Active   21d
openshift-ingress                                  Active   21d
openshift-ingress-canary                           Active   21d
openshift-ingress-operator                         Active   21d
openshift-insights                                 Active   21d
openshift-kni-infra                                Active   21d
openshift-kube-apiserver                           Active   21d
openshift-kube-apiserver-operator                  Active   21d
openshift-kube-controller-manager                  Active   21d
openshift-kube-controller-manager-operator         Active   21d
openshift-kube-scheduler                           Active   21d
openshift-kube-scheduler-operator                  Active   21d
openshift-kube-storage-version-migrator            Active   21d
openshift-kube-storage-version-migrator-operator   Active   21d
openshift-machine-api                              Active   21d
openshift-machine-config-operator                  Active   21d
openshift-marketplace                              Active   21d
openshift-monitoring                               Active   21d
openshift-multus                                   Active   21d
openshift-must-gather-qgqvc                        Active   16d
openshift-network-diagnostics                      Active   21d
openshift-network-node-identity                    Active   21d
openshift-network-operator                         Active   21d
openshift-nfs-storage                              Active   21d
openshift-node                                     Active   21d
openshift-nutanix-infra                            Active   21d
openshift-oauth-apiserver                          Active   21d
openshift-openstack-infra                          Active   21d
openshift-operator-lifecycle-manager               Active   21d
openshift-operators                                Active   21d
openshift-ovirt-infra                              Active   21d
openshift-ovn-kubernetes                           Active   21d
openshift-route-controller-manager                 Active   21d
openshift-service-ca                               Active   21d
openshift-service-ca-operator                      Active   21d
openshift-user-workload-monitoring                 Active   21d
openshift-vsphere-infra                            Active   21d
[root@ce0128-ccmmt-master-0 ~]#

```