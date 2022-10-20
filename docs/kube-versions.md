Kubernetes Feature Version Schema
--------------
- [Feature Gate Version](#feature-gate-version)
  - [Alpha](#alpha)
  - [Beta](#beta)
  - [GA](#ga)
- [API Version](#api-version)
  - [Alpha](#alpha-1)
  - [Beta](#beta-1)
  - [GA](#ga-1)


# Feature Gate Version
## Alpha
* **Disabled by default**.
* Might be buggy. Enabling the feature may expose bugs.
* Support for feature may be dropped at any time without notice.
* The API may change in incompatible ways in a later software release without notice.
* Recommended for use only in short-lived testing clusters, due to increased risk of bugs and lack of long-term support.
## Beta
* **Enabled by default**.
* The feature is well tested. Enabling the feature is considered safe.
* Support for the overall feature will not be dropped, though details may change.
* The schema and/or semantics of objects may change in incompatible ways in a subsequent beta or stable release. When this happens, we will provide instructions for migrating to the next version. This may require deleting, editing, and re-creating API objects. The editing process may require some thought. This may require downtime for applications that rely on the feature.
* Recommended for only non-business-critical uses because of potential for incompatible changes in subsequent releases. If you have multiple clusters that can be upgraded independently, you may be able to relax this restriction.
## GA
* The feature is **always enabled**; you **cannot disable** it.
* The corresponding feature gate is no longer needed.
* Stable versions of features will appear in released software for many subsequent versions


# API Version
## Alpha
* The version names contain alpha (for example, v1alpha1).
* Built-in alpha API versions are **disabled by default** and must be explicitly enabled in the kube-apiserver configuration to be used.
* The software may contain bugs. Enabling a feature may expose bugs.
* Support for an alpha API may be dropped at any time without notice.
* The API may change in incompatible ways in a later software release without notice.
* The software is recommended for use only in short-lived testing clusters, due to increased risk of bugs and lack of long-term support.
## Beta
* The version names contain beta (for example, v2beta3).
* Built-in beta API versions are **disabled by default** and must be explicitly enabled in the kube-apiserver configuration to be used (except for beta versions of APIs introduced prior to Kubernetes 1.22, which were enabled by default).
* Built-in beta API versions have a maximum lifetime of 9 months or 3 minor releases (whichever is longer) from introduction to deprecation, and 9 months or 3 minor releases (whichever is longer) from deprecation to removal.
* The software is well tested. Enabling a feature is considered safe.
* The support for a feature will not be dropped, though the details may change.
* The schema and/or semantics of objects may change in incompatible ways in a subsequent beta or stable API version. When this happens, migration instructions are provided. Adapting to a subsequent beta or stable API version may require editing or re-creating API objects, and may not be straightforward. The migration may require downtime for applications that rely on the feature.
* The software is not recommended for production uses. Subsequent releases may introduce incompatible changes. Use of beta API versions is required to transition to subsequent beta or stable API versions once the beta API version is deprecated and no longer served.
## GA
* The version name is vX where X is an integer.
* Stable API versions remain available for all future releases within a Kubernetes major version, and there are no current plans for a major version revision of Kubernetes that removes stable APIs