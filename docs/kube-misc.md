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

# How to set Kubectl autocomplete
```
source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.

alias k=kubectl
complete -F __start_kubectl k
``

# How to set Kubectl output verbosity and debugging
```
--v=0	Generally useful for this to always be visible to a cluster operator.
--v=1	A reasonable default log level if you don't want verbosity.
--v=2	Useful steady state information about the service and important log messages that may correlate to significant changes in the system. This is the recommended default log level for most systems.
--v=3	Extended information about changes.
--v=4	Debug level verbosity.
--v=5	Trace level verbosity.
--v=6	Display requested resources.
--v=7	Display HTTP request headers.
--v=8	Display HTTP request contents.
--v=9	Display HTTP request contents without truncation of contents.
```