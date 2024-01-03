Cluster Operator and CRD Mapping
------------

# Cluster Baremetal Operator - CBO
# Cloud Credential Operator - CCO
# Cluster Authentication Operator 
# Cluster Autoscaler Operator
# Cluster Cloud Controller Manager Operator
# Cluster CAPI Operator
# Cluster Config Operator
# Cluster CSI Snampshot Controller Operator
# Cluste Image Registry Operator
# Cluster Machine Approver Operator
# Cluster Monitor Operator
# Cluster Network Operator
# Cluster Samples Operator
# Cluster Storage operator
# Cluster Vesion Operator
# Console Operator
# Control Plane Machine Set Operator
# DNS Operator
# ETCD Cluster Operator
# Ingress Operator
# Insights Operator
# Kubernetes API Server Operator
# Kubernetes Controller Manager Operator
# Kubernetes Scheduler Operator
# Kubernetes Sorage Version Migrator Operator
# Machine API Operator
# Machine Config Operator
# MarketePlace Operator
# Node Tuning Operator
# Opesnfhift API Server Operator
# Openshfit Controller Manager Operator
# Operatoer Lifecycle Manager Operator
# vSphere Problem Detector Operator

```bash
[root@ce0128-ccmmt-master-0 ~]# oc get ns | grep operator
openshift-apiserver-operator                       Active   21d
openshift-authentication-operator                  Active   21d
openshift-cloud-controller-manager-operator        Active   21d
openshift-cloud-credential-operator                Active   21d
openshift-cluster-node-tuning-operator             Active   21d
openshift-cluster-samples-operator                 Active   21d
openshift-cluster-storage-operator                 Active   21d
openshift-config-operator                          Active   21d
openshift-console-operator                         Active   21d
openshift-controller-manager-operator              Active   21d
openshift-dns-operator                             Active   21d
openshift-etcd-operator                            Active   21d
openshift-ingress-operator                         Active   21d
openshift-kube-apiserver-operator                  Active   21d
openshift-kube-controller-manager-operator         Active   21d
openshift-kube-scheduler-operator                  Active   21d
openshift-kube-storage-version-migrator-operator   Active   21d
openshift-machine-config-operator                  Active   21d
openshift-network-operator                         Active   21d
openshift-operator-lifecycle-manager               Active   21d
openshift-operators                                Active   21d
openshift-service-ca-operator                      Active   21d
```