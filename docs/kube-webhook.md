Kubernetes Webhook
---

- [Admission Plugin](#admission-plugin)
  - [v1.23](#v123)
    - [Admission Plugin supported - v1.23](#admission-plugin-supported---v123)
    - [Admission Plugin enabled by default - v1.23](#admission-plugin-enabled-by-default---v123)
  - [How to enable/disble admission plugins](#how-to-enabledisble-admission-plugins)
  - [Cluster Wide PodSecurity Level](#cluster-wide-podsecurity-level)

# Admission Plugin
## v1.23
### Admission Plugin supported - v1.23
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
* PodSecurity, 
* PodSecurityPolicy, 
* PodTolerationRestriction, 
* Priority, ResourceQuota, 
* RuntimeClass, 
* SecurityContextDeny, 
* ServiceAccount, 
* StorageObjectInUseProtection, 
* TaintNodesByCondition, 
* ValidatingAdmissionWebhook

### Admission Plugin enabled by default - v1.23

* NamespaceLifecycle,
* LimitRanger,
* ServiceAccount,
* TaintNodesByCondition, 
* **PodSecurity**, 
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

## How to enable/disble admission plugins
* --disable-admission-plugins strings 
* --enable-admission-plugins strings

## Cluster Wide PodSecurity Level

By default, the default PodSecurity level  in cluster wide is "**privileged**" when where is no mode level labed in namespace

```golang
func SetDefaults_PodSecurityDefaults(obj *PodSecurityDefaults) {
        if len(obj.Enforce) == 0 {
                obj.Enforce = string(api.LevelPrivileged)
        }
        if len(obj.Warn) == 0 {
                obj.Warn = string(api.LevelPrivileged)
        }
        if len(obj.Audit) == 0 {
                obj.Audit = string(api.LevelPrivileged)
        }

        if len(obj.EnforceVersion) == 0 {
                obj.EnforceVersion = string(api.VersionLatest)
        }
        if len(obj.WarnVersion) == 0 {
                obj.WarnVersion = string(api.VersionLatest)
        }
        if len(obj.AuditVersion) == 0 {
                obj.AuditVersion = string(api.VersionLatest)
        }
}


type Level string
const (
        LevelPrivileged Level = "privileged"
        LevelBaseline   Level = "baseline"
        LevelRestricted Level = "restricted"
)
var validLevels = []string{
        string(LevelPrivileged),
        string(LevelBaseline),
        string(LevelRestricted),
}
const VersionLatest = "latest"
const AuditAnnotationPrefix = labelPrefix
const (
        labelPrefix = "pod-security.kubernetes.io/"

        EnforceLevelLabel   = labelPrefix + "enforce"
        EnforceVersionLabel = labelPrefix + "enforce-version"
        AuditLevelLabel     = labelPrefix + "audit"
        AuditVersionLabel   = labelPrefix + "audit-version"
        WarnLevelLabel      = labelPrefix + "warn"
        WarnVersionLabel    = labelPrefix + "warn-version"

        ExemptionReasonAnnotationKey = "exempt"
        AuditViolationsAnnotationKey = "audit-violations"
        EnforcedPolicyAnnotationKey  = "enforce-policy"
)

```

Of course it depends on CaaS how to configure cluster wide level. If its default is "**privilged**", then CNF can support PSA in k8s v1.25, in this case, CNF has "privileged" level and then CNF can upgrades to PSA support. 

But in v1.25, how is PSP handled because PSP definaiton and usage in role is still there???

Frankly the ideal upgrade way is:
1. CaaS v1 integrate k8s v1.23 w/o PSA enabled and only support PSP
   1. CNFv1 now only support PSP
2. CaaS upgrade to v2 (k8s 1.24) - both PSP (with default "privileged" psp support) and PSA supported (PSA with default "privileged" enabled)
   1. CNF no impact
   2. CNF upgrade to CNFv2 with PSA only
3. when all CNF upgrades completes, CaaS shall disable PSP and update default PSA with "restricted" in Cluster wide

* --admission-control-config-file
```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: PodSecurity
  configuration:
    apiVersion: pod-security.admission.config.k8s.io/v1beta1
    kind: PodSecurityConfiguration
    # Defaults applied when a mode label is not set.
    #
    # Level label values must be one of:
    # - "privileged" (default)
    # - "baseline"
    # - "restricted"
    #
    # Version label values must be one of:
    # - "latest" (default) 
    # - specific version like "v1.23"
    defaults:
      enforce: "privileged"
      enforce-version: "latest"
      audit: "privileged"
      audit-version: "latest"
      warn: "privileged"
      warn-version: "latest"
    exemptions:
      # Array of authenticated usernames to exempt.
      usernames: []
      # Array of runtime class names to exempt.
      runtimeClassNames: []
      # Array of namespaces to exempt.
      namespaces: []
```