https://github.com/orgs/openshift/repositories?q=operator&type=all&language=&sort=


CRDs

```bash
[root@ce0128-ccmmt-master-0 ~]# oc get crd | grep openshift
alertingrules.monitoring.openshift.io                             2023-12-07T05:45:32Z # Mapped
alertrelabelconfigs.monitoring.openshift.io                       2023-12-07T05:45:38Z # Mapped
apirequestcounts.apiserver.openshift.io                           2023-12-07T05:45:15Z
apiservers.config.openshift.io                                    2023-12-07T05:44:50Z # Mapped
authentications.config.openshift.io                               2023-12-07T05:44:50Z # Mapped
authentications.operator.openshift.io                             2023-12-07T05:45:34Z # Mapped
builds.config.openshift.io                                        2023-12-07T05:45:30Z # Mapped
cloudcredentials.operator.openshift.io                            2023-12-07T05:45:16Z # Mapped
clusterautoscalers.autoscaling.openshift.io                       2023-12-07T05:45:31Z # Mapped
clustercsidrivers.operator.openshift.io                           2023-12-07T05:45:57Z # Mapped
clusteroperators.config.openshift.io                              2023-12-07T05:44:39Z # Mapped
clusterresourcequotas.quota.openshift.io                          2023-12-07T05:44:49Z # Mapped
clusterversions.config.openshift.io                               2023-12-07T05:44:39Z # Mapped
configs.imageregistry.operator.openshift.io                       2023-12-07T05:45:33Z # Mapped
configs.operator.openshift.io                                     2023-12-07T05:45:36Z # Mapped
configs.samples.operator.openshift.io                             2023-12-07T05:45:31Z # Mapped
consoleclidownloads.console.openshift.io                          2023-12-07T05:45:30Z # Mapped
consoleexternalloglinks.console.openshift.io                      2023-12-07T05:45:30Z # Mapped
consolelinks.console.openshift.io                                 2023-12-07T05:45:30Z # Mapped
consolenotifications.console.openshift.io                         2023-12-07T05:45:30Z # Mapped
consoleplugins.console.openshift.io                               2023-12-07T05:45:30Z # Mapped
consolequickstarts.console.openshift.io                           2023-12-07T05:45:30Z # Mapped
consoles.config.openshift.io                                      2023-12-07T05:44:51Z # Mapped
consoles.operator.openshift.io                                    2023-12-07T05:45:30Z # Mapped
consolesamples.console.openshift.io                               2023-12-07T05:45:30Z # Mapped
consoleyamlsamples.console.openshift.io                           2023-12-07T05:45:30Z # Mapped
containerruntimeconfigs.machineconfiguration.openshift.io         2023-12-07T05:45:45Z # Mapped
controllerconfigs.machineconfiguration.openshift.io               2023-12-07T06:04:44Z # Mapped
controlplanemachinesets.machine.openshift.io                      2023-12-07T05:45:32Z # Mapped
credentialsrequests.cloudcredential.openshift.io                  2023-12-07T05:45:16Z # Mapped
csisnapshotcontrollers.operator.openshift.io                      2023-12-07T05:45:32Z # Mapped
dnses.config.openshift.io                                         2023-12-07T05:44:51Z # Mapped
dnses.operator.openshift.io                                       2023-12-07T05:45:35Z # Mapped
dnsrecords.ingress.operator.openshift.io                          2023-12-07T05:45:35Z # Mapped
egressrouters.network.operator.openshift.io                       2023-12-07T05:45:38Z # Mapped
etcds.operator.openshift.io                                       2023-12-07T05:45:30Z # Mapped
featuregates.config.openshift.io                                  2023-12-07T05:44:52Z # Mapped
helmchartrepositories.helm.openshift.io                           2023-12-07T05:45:30Z # Mapped
imagecontentpolicies.config.openshift.io                          2023-12-07T05:44:52Z # Mapped
imagecontentsourcepolicies.operator.openshift.io                  2023-12-07T05:44:53Z # Mapped
imagedigestmirrorsets.config.openshift.io                         2023-12-07T05:44:53Z # Mapped
imagepruners.imageregistry.operator.openshift.io                  2023-12-07T05:45:53Z # Mapped
images.config.openshift.io                                        2023-12-07T05:44:52Z # Mapped
imagetagmirrorsets.config.openshift.io                            2023-12-07T05:44:54Z # Mapped
infrastructures.config.openshift.io                               2023-12-07T05:44:54Z # Mapped
ingresscontrollers.operator.openshift.io                          2023-12-07T05:45:19Z # Mapped
ingresses.config.openshift.io                                     2023-12-07T05:44:54Z # Mapped
insightsoperators.operator.openshift.io                           2023-12-07T05:46:00Z # Mapped
kubeapiservers.operator.openshift.io                              2023-12-07T05:45:55Z # Mapped
kubecontrollermanagers.operator.openshift.io                      2023-12-07T05:45:35Z # Mapped
kubeletconfigs.machineconfiguration.openshift.io                  2023-12-07T05:45:46Z # Mapped
kubeschedulers.operator.openshift.io                              2023-12-07T05:45:35Z # Mapped
kubestorageversionmigrators.operator.openshift.io                 2023-12-07T05:45:30Z # Mapped
machineautoscalers.autoscaling.openshift.io                       2023-12-07T05:45:34Z # Mapped
machineconfigpools.machineconfiguration.openshift.io              2023-12-07T05:45:49Z # Mapped
machineconfigs.machineconfiguration.openshift.io                  2023-12-07T05:45:48Z # mapped
machinehealthchecks.machine.openshift.io                          2023-12-07T05:45:57Z # Mapped
machines.machine.openshift.io                                     2023-12-07T05:45:56Z # Mapped
machinesets.machine.openshift.io                                  2023-12-07T05:45:57Z # Mapped
networks.config.openshift.io                                      2023-12-07T05:44:55Z # Mapped
networks.operator.openshift.io                                    2023-12-07T05:45:34Z # Mapped
nodes.config.openshift.io                                         2023-12-07T05:44:55Z # Mapped
oauths.config.openshift.io                                        2023-12-07T05:44:56Z # Mapped
openshiftapiservers.operator.openshift.io                         2023-12-07T05:45:30Z # Mapped
openshiftcontrollermanagers.operator.openshift.io                 2023-12-07T05:45:34Z # Mapped
operatorhubs.config.openshift.io                                  2023-12-07T05:45:30Z # Mapped
operatorpkis.network.operator.openshift.io                        2023-12-07T05:45:40Z # Mapped
performanceprofiles.performance.openshift.io                      2023-12-07T05:45:34Z # Mapped
podnetworkconnectivitychecks.controlplane.operator.openshift.io   2023-12-07T06:28:05Z # Mapped
profiles.tuned.openshift.io                                       2023-12-07T05:45:35Z # Mapped
projecthelmchartrepositories.helm.openshift.io                    2023-12-07T05:45:30Z # Mapped
projects.config.openshift.io                                      2023-12-07T05:44:56Z # Mapped
proxies.config.openshift.io                                       2023-12-07T05:44:49Z # Mapped
rangeallocations.security.internal.openshift.io                   2023-12-07T05:44:50Z # Mapped
rolebindingrestrictions.authorization.openshift.io                2023-12-07T05:44:49Z # Mapped
schedulers.config.openshift.io                                    2023-12-07T05:44:56Z # Mapped
securitycontextconstraints.security.openshift.io                  2023-12-07T05:44:49Z # Mapped
servicecas.operator.openshift.io                                  2023-12-07T05:45:35Z # Mapped
storages.operator.openshift.io                                    2023-12-07T05:45:57Z # Mapped
tuneds.tuned.openshift.io                                         2023-12-07T05:45:37Z # Mapped
[root@ce0128-ccmmt-master-0 ~]#
```