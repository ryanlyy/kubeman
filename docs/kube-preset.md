Pod Presets
---

# Pod Preset Basic
A PodPreset is an API resource for injecting additional runtime requirements into a Pod at creation time using .spec.selector.matchLabels.

# Enable PodPreset in cluster

NCS Configuration on **kube-apiserverss**

* Enable the API type: settings.k8s.io/v1alpha1/podpreset

  **--runtime-config=**  
    * scheduling.k8s.io/v1beta1=true,
    * admissionregistration.k8s.io/v1beta1=true,
    * **settings.k8s.io/v1alpha1=true**


* Enable the admission controller named PodPreset

  **--enable-admission-plugins=**
    * NamespaceLifecycle,
    * LimitRanger,
    * ServiceAccount,
    * DefaultStorageClass,
    * NodeRestriction,
    * Priority,
    * PodSecurityPolicy,
    * MutatingAdmissionWebhook,
    * ValidatingAdmissionWebhook,
    * ResourceQuota,
    * **PodPreset**,
    * AlwaysPullImages

# Disable Pod Preset for a specific pod
  ```
  .spec.podpreset.admission.kubernetes.io/exclude: "true"
  ```

# Pod Preset Example
```
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      role: frontend
  env:
    - name: DB_PORT
      value: "6379"
  volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
```

# User Cases
* Simplifer application manfiest
* Common Defination
* Add common information for a lot of manifests 
  * this case can save coding efforts


# Kube admission plugin

v1.18.8

* default admission plugin
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
	  
* Supported admission plugin
  * AlwaysAdmit, 
  * AlwaysDeny, 
  * AlwaysPullImages, 
  * CertificateApproval, 
  * CertificateSigning, 
  * CertificateSubjectRestriction, 
  * DefaultIngressClass, 
  * DefaultStorageClass, 
  * DefaultTolerationSeconds, 
  * DenyEscalatingExec, 
  * DenyExecOnPrivileged, 
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
  * PodPreset, 
  * PodSecurityPolicy, 
  * PodTolerationRestriction, 
  * Priority, 
  * ResourceQuota, 
  * RuntimeClass, 
  * SecurityContextDeny, 
  * ServiceAccount, 
  * StorageObjectInUseProtection, 
  * TaintNodesByCondition, 
  * ValidatingAdmissionWebhook. 