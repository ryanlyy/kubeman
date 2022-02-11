Kubernetes Webhook
---

- [Admission Plugin](#admission-plugin)
  - [v1.23](#v123)
    - [Admission Plugin supported - v1.23](#admission-plugin-supported---v123)
    - [Admission Plugin enabled by default - v1.23](#admission-plugin-enabled-by-default---v123)
  - [How to enable/disble admission plugins](#how-to-enabledisble-admission-plugins)
- [Cluster Wide PodSecurity Level](#cluster-wide-podsecurity-level)
- [MutatingAdmissionWebhook & ValidatingAdmissionWebhook](#mutatingadmissionwebhook--validatingadmissionwebhook)
  - [What are admission webhooks?](#what-are-admission-webhooks)
  - [Prerequisites](#prerequisites)
  - [Write an admission webhook server](#write-an-admission-webhook-server)
  - [Deploy the admission webhook service](#deploy-the-admission-webhook-service)
  - [Configure admission webhooks on the fly](#configure-admission-webhooks-on-the-fly)
    - [Matching request: rule](#matching-request-rule)
  - [Contacting the webhook](#contacting-the-webhook)
  - [Examples](#examples)

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

# Cluster Wide PodSecurity Level

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

# MutatingAdmissionWebhook & ValidatingAdmissionWebhook

This admission controller calls any mutating webhooks which match the request. Matching webhooks are called in **serial**; each one may modify the object if it desires.

This admission controller (as implied by the name) only runs in the mutating phase.

In addition to compiled-in admission plugins, admission plugins can be developed as extensions and run as webhooks configured at runtime. This page describes how to build, configure, use, and monitor admission webhooks.

## What are admission webhooks?
Admission webhooks are HTTP callbacks that receive admission requests and do something with them. 

You can define two types of admission webhooks
* validating admission webhook
* mutating admission webhook. 
 
Mutating admission webhooks are invoked first, and can modify objects sent to the API server to enforce custom defaults. After all object modifications are complete, and after the incoming object is validated by the API server, validating admission webhooks are invoked and can reject requests to enforce custom policies.

Admission webhooks are essentially part of the **cluster control-plane**

## Prerequisites
* v1.16 (to use admissionregistration.k8s.io/v1), or v1.9 (to use admissionregistration.k8s.io/v1beta1)
* Ensure that MutatingAdmissionWebhook and ValidatingAdmissionWebhook admission controllers are enabled by --enable-admission-plugins. by default they are enabled by k8s
* admissionregistration.k8s.io/v1 or admissionregistration.k8s.io/v1beta1 API is enabled

## Write an admission webhook server
N/A
https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#write-an-admission-webhook-server

## Deploy the admission webhook service
N/A
https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#deploy-the-admission-webhook-service

## Configure admission webhooks on the fly
dynamically configure what resources are subject to what admission webhooks via ValidatingWebhookConfiguration or MutatingWebhookConfiguration.

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: "pod-policy.example.com"
webhooks:
- name: "pod-policy.example.com"
  rules:
  - apiGroups:   [""]
    apiVersions: ["v1"]
    operations:  ["CREATE"]
    resources:   ["pods"]
    scope:       "Namespaced"
  clientConfig:
    service:
      namespace: "example-namespace"
      name: "example-service"
    caBundle: "Ci0tLS0tQk...<`caBundle` is a PEM encoded CA bundle which will be used to validate the webhook's server certificate.>...tLS0K"
  admissionReviewVersions: ["v1", "v1beta1"]
  sideEffects: None
  timeoutSeconds: 5
```

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
...
webhooks:
- name: my-webhook.example.com
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: ["apps"]
    apiVersions: ["v1", "v1beta1"]
    resources: ["deployments", "replicasets"]
    scope: "Namespaced"
  ...
```

### Matching request: rule
Each webhook must specify a list of rules used to determine if a request to the API server should be sent to the webhook. Each rule specifies one or more operations, apiGroups, apiVersions, and resources, and a resource scope:

* operations lists one or more operations to match. Can be "CREATE", "UPDATE", "DELETE", "CONNECT", or "*" to match all.
* apiGroups lists one or more API groups to match. "" is the core API group. "*" matches all API groups.
* apiVersions lists one or more API versions to match. "*" matches all API versions.
* resources lists one or more resources to match.
  * "*" matches all resources, but not subresources.
  * "*/*" matches all resources and subresources.
  * "pods/*" matches all subresources of pods.
  * "*/status" matches all status subresources.
* scope specifies a scope to match. Valid values are "Cluster", "Namespaced", and "*". Subresources match the scope of their parent resource. Supported in v1.14+. Default is "*", matching pre-1.14 behavior.
  * "Cluster" means that only cluster-scoped resources will match this rule (Namespace API objects are cluster-scoped).
  * "Namespaced" means that only namespaced resources will match this rule.
  * "*" means that there are no scope restrictions.

If an incoming request matches one of the specified operations, groups, versions, resources, and scope for any of a webhook's rules, the request is sent to the webhook.

## Contacting the webhook
Once the API server has determined a request should be sent to a webhook, it needs to know how to contact the webhook. This is specified in the clientConfig stanza of the webhook configuration.

Webhooks can either be called via a URL or a service reference, and can optionally include a custom CA bundle to use to verify the TLS connection

## Examples
[Webhook Examples](../webhook/DLB%20IP%20fixing.zip)