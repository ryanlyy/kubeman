Kuberntes Tips
---

- [podman started container log location](#podman-started-container-log-location)
- [How to get pod name](#how-to-get-pod-name)
- [How to set Kubernetes Resource Namespace](#how-to-set-kubernetes-resource-namespace)
- [How to rejoin node](#how-to-rejoin-node)
- [How to list supported kubernetes versions](#how-to-list-supported-kubernetes-versions)
- [How to set default namespace for kubectl](#how-to-set-default-namespace-for-kubectl)
- [How to set ENV from Spec](#how-to-set-env-from-spec)
- [How to set Kubectl autocomplete](#how-to-set-kubectl-autocomplete)
- [How to set Kubectl output verbosity and debugging](#how-to-set-kubectl-output-verbosity-and-debugging)
- [How to get all resource of specific namespaces](#how-to-get-all-resource-of-specific-namespaces)
- [What is default resource gernated when creating namespaces](#what-is-default-resource-gernated-when-creating-namespaces)
- [Default mount volume when creating pod in kube 1.21](#default-mount-volume-when-creating-pod-in-kube-121)
- [Which kubeconfig shall be used by kubectl](#which-kubeconfig-shall-be-used-by-kubectl)
- [namespace configured in manifest has high priority than value specified in helm install](#namespace-configured-in-manifest-has-high-priority-than-value-specified-in-helm-install)

# podman started container log location
for example: kube-apiserver

/data0/podman/storage/overlay-containers/$(podman ps --no-trunc | grep apiserver| awk '{ print $1 }')/userdata/ctr.log

# How to get pod name
```bash
kubectl get pod -n zts -l "app=cmcontroller"
kubectl get pods  -o custom-columns=":metadata.name" -n zts -l "app=cmcontroller"
kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l "app=cmcontroller" -n zts
```
# How to set Kubernetes Resource Namespace
* helm -n <ns>
* kubectl -n <ns>
* .metadata.namespace: tstbed

NOTE: .metadata.namespace will override helm/kubectl -n <ns>

# How to rejoin node
```bash
root@k8s-controler-1:~# kubeadm token generate
og6new.brkrzpjdnfnsmupq
root@k8s-controler-1:~# kubeadm token create og6new.brkrzpjdnfnsmupq --print-join-command
kubeadm join 192.168.122.250:9443 --token og6new.brkrzpjdnfnsmupq --discovery-token-ca-cert-hash sha256:9a597ff94b2359e0b3d9d18add4e741ccab01293d6db3b43ec67d54af7331d2d 

```
# How to list supported kubernetes versions
```bash
curl -s https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages | grep Version
```
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
```

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

# How to get all resource of specific namespaces
[lstres.sh](../src/lsres.sh)

# What is default resource gernated when creating namespaces
  at the least the following:

  ```
  root@k8s-controler-1:~/istio/security# kubectl get sa -n test
  NAME      SECRETS   AGE
  default   1         21h
  root@k8s-controler-1:~/istio/security# kubectl get secret -n test
  NAME                  TYPE                                  DATA   AGE
  default-token-2pjhr   kubernetes.io/service-account-token   3      21h
  ```

# Default mount volume when creating pod in kube 1.21
```
   volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-x2gfp
      readOnly: true

  volumes:
  - name: kube-api-access-x2gfp
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
```

```
# pwd
/var/run/secrets/kubernetes.io/serviceaccount
# ls -l
total 0
lrwxrwxrwx 1 root root 13 Jun 17 05:54 ca.crt -> ..data/ca.crt
lrwxrwxrwx 1 root root 16 Jun 17 05:54 namespace -> ..data/namespace
lrwxrwxrwx 1 root root 12 Jun 17 05:54 token -> ..data/token
```

# Which kubeconfig shall be used by kubectl
  * use --kubeconfig flag, if specified
  * use KUBECONFIG environment variable, if specified
  * use $HOME/.kube/config file

# namespace configured in manifest has high priority than value specified in helm install
```yaml
apiVersion: apps/v1
#kind: ReplicaSet
kind: Deployment
metadata:
  name: {{ include "tstbed.fullname" . }}
  namespace: tstbed
  labels:
    {{- include "tstbed.labels" . | nindent 4 }}
spec:
```

```bash
helm3 install abc ./tstbed -n test
```

The deployment resource is deployed in tstbed instead of test.