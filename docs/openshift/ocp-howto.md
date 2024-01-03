

# How to check removed API called by workload
use the APIRequestCount API to track API requests and review whether any of them are using one of the removed APIs.

```bash
[root@ce0128-ccmmt-master-0 ~]# oc get apirequestcounts
NAME                                                                           REMOVEDINRELEASE   REQUESTSINCURRENTHOUR   REQUESTSINLAST24H
adminpolicybasedexternalroutes.v1.k8s.ovn.org                                                     37                      2686
alertingrules.v1.monitoring.openshift.io                                                          11                      543
alertmanagerconfigs.v1alpha1.monitoring.coreos.com                                                3                       175
alertmanagerconfigs.v1beta1.monitoring.coreos.com                                                 6                       362
alertmanagers.v1.monitoring.coreos.com                                                            46                      2675
alertrelabelconfigs.v1.monitoring.openshift.io                                                    8                       539
apirequestcounts.v1.apiserver.openshift.io                                                        5406                    388083
apiservers.v1.config.openshift.io                                                                 35                      2265
apiservices.v1.apiregistration.k8s.io                                                             1378                    95360
authentications.v1.config.openshift.io                                                            42                      3310
authentications.v1.operator.openshift.io                                                          435                     25037
baremetalhosts.v1alpha1.metal3.io                                                                 7                       358
bmceventsubscriptions.v1alpha1.metal3.io                                                          5                       357
...
```