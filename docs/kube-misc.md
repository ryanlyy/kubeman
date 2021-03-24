Kuberntes Tips
---

- [How to set default namespace for kubectl](#how-to-set-default-namespace-for-kubectl)
- [How to set ENV from Spec](#how-to-set-env-from-spec)
# How to set default namespace for kubectl

```
kubectl config set-context --current --namespace=<insert-namespace-name-here>
```
how to validate:

```
kubectl config view | grep namespace
```

# How to set ENV from Spec

```
    - name: NODE_HOSTNAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: spec.nodeName
    - name: POD_IP
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: status.podIP

```