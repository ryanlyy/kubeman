Kubernees Feature Enablement Checker
---
This project is used to check feature enabled or not by kubernetes components

- [Probe](#probe)
- [Hooks](#hooks)
- [Admission-plugin](#admission-plugin)
- [Feature-gate](#feature-gate)


# Probe
* startupProbe
* livenessProbe
* readinessProbe
  
# Hooks
* Helm 
  
  Helm provides a hook mechanism to allow chart developers to intervene at certain points in a release's life cycle.
  
  * helm lcm command: **install, delete, upgrade, rollback**
  
  | Annotation Value | Description |
  | --- | --- |
  | pre-install	| Executes after templates are rendered, but before any resources are created in Kubernetes |
  | post-install | Executes after all resources are loaded into Kubernetes |
  | pre-delete | Executes on a deletion request before any resources are deleted from Kubernetes |
  | post-delete | Executes on a deletion request after all of the release's resources have been deleted |
  | pre-upgrade | Executes on an upgrade request after templates are rendered, but before any resources are updated |
  | post-upgrade | Executes on an upgrade request after all resources have been upgraded |
  | pre-rollback | Executes on a rollback request after templates are rendered, but before any resources are rolled back |
  | post-rollback | Executes on a rollback request after all resources have been modified |

  * How to define hook

    hook is defined in manifest **annotations**.
    ```
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: "{{ .Release.Name }}"
      annotations:
        "helm.sh/hook": post-install,...                    # Multiple hooks
        "helm.sh/hook-weight": "-5"                         # weight for a hook which will help build a deterministic executing order in ascending order
        "helm.sh/hook-delete-policy": hook-succeeded        # policies that determine when to delete corresponding hook resources.
      ...
    ```

    | Annotation Value | Description |
    | --- | -- |
    | before-hook-creation | Delete the previous resource before a new hook is launched (default) |
    | hook-succeeded | Delete the resource after the hook is successfully executed |
    | hook-failed | Delete the resource if the hook failed during execution |

* Kubernetes container
  * Example
    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: lifecycle-demo
    spec:
      containers:
      - name: lifecycle-demo-container
        image: nginx
        lifecycle:
          postStart:
            exec:
              command: ["/bin/sh", "-c", "echo Hello from the postStart handler /usr/share/message"]
          preStop:
            exec:
              command: ["/bin/sh","-c","nginx -s quit; while killall -0 nginx; do sleep 1; done"]
    ```


# Admission-plugin
**v1.21 Default**

* NamespaceLifecycle, 
* LimitRanger, 
* ServiceAccount, 
* TaintNodesByCondition, 
* Priority, 
* DefaultTolerationSeconds, 
* DefaultStorageClass, 
* StorageObjectInUseProtection,               
* PersistentVolumeClaimResize, 
* RuntimeClass, 
* CertificateApproval, 
* CertificateSigning, 
* CertificateSubjectRestriction,
* DefaultIngressClass, 
* MutatingAdmissionWebhook, 
* ValidatingAdmissionWebhook, 
* ResourceQuota

**Admission plugin list**
* AlwaysAdmit, 
* AlwaysDeny, 
* AlwaysPullImages, 
* CertificateApproval, 
* CertificateSigning, 
* CertificateSubjectRestriction, 
* DefaultIngressClass, 
* DefaultStorageClass,
* DefaultTolerationSeconds, 
* DenyServiceExternalIPs, 
* EventRateLimit,
* ExtendedResourceToleration, 
* ImagePolicyWebhook, 
* LimitPodHardAntiAffinityTopology, 
* LimitRanger, 
* MutatingAdmissionWebhook, 
* NamespaceAutoProvision, 
* NamespaceExists, 
* NamespaceLifecycle, 
* NodeRestriction, 
* OwnerReferencesPermissionEnforcement,
* PersistentVolumeClaimResize, 
* PersistentVolumeLabel, 
* PodNodeSelector, 
* PodSecurityPolicy, 
* PodTolerationRestriction, 
* Priority, 
* ResourceQuota, 
* RuntimeClass, 
* SecurityContextDeny, 
* ServiceAccount, 
* StorageObjectInUseProtection, 
* TaintNodesByCondition,
* ValidatingAdmissionWebhook

# Feature-gate
A set of key=value pairs that describe feature gates for alpha/experimental features. Options are:

* APIListChunking=true|false (BETA - default=true)
* APIPriorityAndFairness=true|false (BETA - default=true)
* APIResponseCompression=true|false (BETA - default=true)
* APIServerIdentity=true|false (ALPHA - default=false)
* AllAlpha=true|false (ALPHA - default=false)
* AllBeta=true|false (BETA - default=false)
* AnyVolumeDataSource=true|false (ALPHA - default=false)
* AppArmor=true|false (BETA - default=true)
* BalanceAttachedNodeVolumes=true|false (ALPHA - default=false)
* BoundServiceAccountTokenVolume=true|false (BETA - default=true)
* CPUManager=true|false (BETA - default=true)
* CSIInlineVolume=true|false (BETA - default=true)
* CSIMigration=true|false (BETA - default=true)
* CSIMigrationAWS=true|false (BETA - default=false)
* CSIMigrationAzureDisk=true|false (BETA - default=false)
* CSIMigrationAzureFile=true|false (BETA - default=false)
* CSIMigrationGCE=true|false (BETA - default=false)
* CSIMigrationOpenStack=true|false (BETA - default=true)
* CSIMigrationvSphere=true|false (BETA - default=false)
* CSIMigrationvSphereComplete=true|false (BETA - default=false)
* CSIServiceAccountToken=true|false (BETA - default=true)
* CSIStorageCapacity=true|false (BETA - default=true)
* CSIVolumeFSGroupPolicy=true|false (BETA - default=true)
* CSIVolumeHealth=true|false (ALPHA - default=false)
* ConfigurableFSGroupPolicy=true|false (BETA - default=true)
* CronJobControllerV2=true|false (BETA - default=true)
* CustomCPUCFSQuotaPeriod=true|false (ALPHA - default=false)
* DaemonSetUpdateSurge=true|false (ALPHA - default=false)
* DefaultPodTopologySpread=true|false (BETA - default=true)
* DevicePlugins=true|false (BETA - default=true)
* DisableAcceleratorUsageMetrics=true|false (BETA - default=true)
* DownwardAPIHugePages=true|false (BETA - default=false)
* DynamicKubeletConfig=true|false (BETA - default=true)
* EfficientWatchResumption=true|false (BETA - default=true)
* EndpointSliceProxying=true|false (BETA - default=true)
* EndpointSliceTerminatingCondition=true|false (ALPHA - default=false)
* EphemeralContainers=true|false (ALPHA - default=false)
* ExpandCSIVolumes=true|false (BETA - default=true)
* ExpandInUsePersistentVolumes=true|false (BETA - default=true)
* ExpandPersistentVolumes=true|false (BETA - default=true)
* ExperimentalHostUserNamespaceDefaulting=true|false (BETA - default=false)
* GenericEphemeralVolume=true|false (BETA - default=true)
* GracefulNodeShutdown=true|false (BETA - default=true)
* HPAContainerMetrics=true|false (ALPHA - default=false)
* HPAScaleToZero=true|false (ALPHA - default=false)
* HugePageStorageMediumSize=true|false (BETA - default=true)
* IPv6DualStack=true|false (BETA - default=true)
* InTreePluginAWSUnregister=true|false (ALPHA - default=false)
* InTreePluginAzureDiskUnregister=true|false (ALPHA - default=false)
* InTreePluginAzureFileUnregister=true|false (ALPHA - default=false)
* InTreePluginGCEUnregister=true|false (ALPHA - default=false)
* InTreePluginOpenStackUnregister=true|false (ALPHA - default=false)
* InTreePluginvSphereUnregister=true|false (ALPHA - default=false)
* IndexedJob=true|false (ALPHA - default=false)
* IngressClassNamespacedParams=true|false (ALPHA - default=false)
* KubeletCredentialProviders=true|false (ALPHA - default=false)
* KubeletPodResources=true|false (BETA - default=true)
* KubeletPodResourcesGetAllocatable=true|false (ALPHA - default=false)
* LocalStorageCapacityIsolation=true|false (BETA - default=true)
* LocalStorageCapacityIsolationFSQuotaMonitoring=true|false (ALPHA - default=false)
* LogarithmicScaleDown=true|false (ALPHA - default=false)
* MemoryManager=true|false (ALPHA - default=false)
* MixedProtocolLBService=true|false (ALPHA - default=false)
* NamespaceDefaultLabelName=true|false (BETA - default=true)
* NetworkPolicyEndPort=true|false (ALPHA - default=false)
* NonPreemptingPriority=true|false (BETA - default=true)
* PodAffinityNamespaceSelector=true|false (ALPHA - default=false)
* PodDeletionCost=true|false (ALPHA - default=false)
* PodOverhead=true|false (BETA - default=true)
* PreferNominatedNode=true|false (ALPHA - default=false)
* ProbeTerminationGracePeriod=true|false (ALPHA - default=false)
* ProcMountType=true|false (ALPHA - default=false)
* QOSReserved=true|false (ALPHA - default=false)
* RemainingItemCount=true|false (BETA - default=true)
* RemoveSelfLink=true|false (BETA - default=true)
* RotateKubeletServerCertificate=true|false (BETA - default=true)
* ServerSideApply=true|false (BETA - default=true)
* ServiceInternalTrafficPolicy=true|false (ALPHA - default=false)
* ServiceLBNodePortControl=true|false (ALPHA - default=false)
* ServiceLoadBalancerClass=true|false (ALPHA - default=false)
* ServiceTopology=true|false (ALPHA - default=false)
* SetHostnameAsFQDN=true|false (BETA - default=true)
* SizeMemoryBackedVolumes=true|false (ALPHA - default=false)
* StorageVersionAPI=true|false (ALPHA - default=false)
* StorageVersionHash=true|false (BETA - default=true)
* SuspendJob=true|false (ALPHA - default=false)
* TTLAfterFinished=true|false (BETA - default=true)
* TopologyAwareHints=true|false (ALPHA - default=false)
* TopologyManager=true|false (BETA - default=true)
* ValidateProxyRedirects=true|false (BETA - default=true)
* VolumeCapacityPriority=true|false (ALPHA - default=false)
* WarningHeaders=true|false (BETA - default=true)
* WinDSR=true|false (ALPHA - default=false)
* WinOverlay=true|false (BETA - default=true)
* WindowsEndpointSliceProxying=true|false (BETA - default=true)
