
- [Bound Service Account Token](#bound-service-account-token)
- [LegacyServiceAccountTokenNoAutoGeneration](#legacyserviceaccounttokennoautogeneration)
- [Opt out of API credential automounting](#opt-out-of-api-credential-automounting)
- [Accessing the API from a Pod](#accessing-the-api-from-a-pod)


# Bound Service Account Token
 We would like to introduce a new mechanism for provisioning Kubernetes service account tokens that is compatible with our current security and scalability requirements.

This projected volume consists of three sources:

1. A ServiceAccountToken acquired from kube-apiserver via TokenRequest API. It will expire after 1 hour by default or when the pod is deleted. It is bound to the pod and has kube-apiserver as the audience.

2. A ConfigMap containing a CA bundle used for verifying connections to the kube-apiserver. This feature depends on the RootCAConfigMap feature gate, which publishes a "kube-root-ca.crt" ConfigMap to every namespace. RootCAConfigMap feature gate is graduated to GA in 1.21 and default to true. (This flag will be removed from --feature-gate arg in 1.22)

3. A DownwardAPI that references the namespace of the pod.


# LegacyServiceAccountTokenNoAutoGeneration
* k8s v1.24 Beta
* k8s v1.26 GA

```yaml
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-z7gkd
      readOnly: true
 

  volumes:
  - name: kube-api-access-z7gkd
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
```bash
bash-4.4$ ls -l /var/run/secrets/kubernetes.io/serviceaccount/
total 0
lrwxrwxrwx 1 root root 13 Aug  1 05:13 ca.crt -> ..data/ca.crt
lrwxrwxrwx 1 root root 16 Aug  1 05:13 namespace -> ..data/namespace
lrwxrwxrwx 1 root root 12 Aug  1 05:13 token -> ..data/token
bash-4.4$ 

root@tstbed-1:~# k get sa  -o yaml default
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2023-06-30T02:55:10Z"
  name: default
  namespace: default
  resourceVersion: "357"
  uid: af2535eb-8980-485d-a1a5-fa2a10219306
root@tstbed-1:~# k get cm
NAME                 DATA   AGE
istio-ca-root-cert   1      37d
kube-root-ca.crt     1      52d
root@tstbed-1:~# 
```

Versions of Kubernetes before v1.22 automatically created long term credentials for accessing the Kubernetes API. This older mechanism was based on creating token Secrets that could then be mounted into running Pods. In more recent versions, including Kubernetes v1.28, API credentials are obtained directly by using the TokenRequest API, and are mounted into Pods using a projected volume. The tokens obtained using this method have bounded lifetimes, and are automatically invalidated when the Pod they are mounted into is deleted.

# Opt out of API credential automounting
If you don't want the kubelet to automatically mount a ServiceAccount's API credentials, you can opt out of the default behavior. You can opt out of automounting API credentials on /var/run/secrets/kubernetes.io/serviceaccount/token for a service account by setting automountServiceAccountToken: false on the ServiceAccount:

For example:
```yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
automountServiceAccountToken: false
...

apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: build-robot
  automountServiceAccountToken: false
  ...
```

# Accessing the API from a Pod
When accessing the API from a pod, locating and authenticating to the API server are somewhat different.

https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/

The recommended way to authenticate to the API server is with a service account credential. By default, a Pod is associated with a service account, and a credential (token) for that service account is placed into the filesystem tree of each container in that Pod, at /var/run/secrets/kubernetes.io/serviceaccount/token.

If available, a certificate bundle is placed into the filesystem tree of each container at /var/run/secrets/kubernetes.io/serviceaccount/ca.crt, and should be used to verify the serving certificate of the API server.

Finally, the default namespace to be used for namespaced API operations is placed in a file at /var/run/secrets/kubernetes.io/serviceaccount/namespace in each container

To assign a ServiceAccount to a Pod, you set the spec.serviceAccountName field in the Pod specification. Kubernetes then automatically provides the credentials for that ServiceAccount to the Pod. In v1.22 and later, Kubernetes gets a short-lived, automatically rotating token using the TokenRequest API and mounts the token as a projected volume.

By default, Kubernetes provides the Pod with the credentials for an assigned ServiceAccount, whether that is the default ServiceAccount or a custom ServiceAccount that you specify.

To prevent Kubernetes from automatically injecting credentials for a specified ServiceAccount or the default ServiceAccount, set the automountServiceAccountToken field in your Pod specification to false.

In versions earlier than 1.22, Kubernetes provides a long-lived, static token to the Pod as a Secret