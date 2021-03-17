Kubernees Feature Enablement Checker
---
This project is used to check feature enabled or not by kubernetes components

- [Probe](#probe)
- [Hooks](#hooks)


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


