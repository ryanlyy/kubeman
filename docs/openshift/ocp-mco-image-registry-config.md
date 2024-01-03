
# Configuring image registry settings

You can configure image registry settings by editing the image.config.openshift.io/cluster custom resource (CR). When changes to the registry are applied to the image.config.openshift.io/cluster CR, the Machine Config Operator (MCO) performs the following sequential actions:

* Cordons the node
* Applies changes by restarting CRI-O
* Uncordons the node

https://docs.openshift.com/container-platform/4.14/openshift_images/image-configuration.html#images-configuration-file_image-configuration

```yaml
apiVersion: config.openshift.io/v1
kind: Image 
metadata:
  annotations:
    release.openshift.io/create-only: "true"
  creationTimestamp: "2019-05-17T13:44:26Z"
  generation: 1
  name: cluster
  resourceVersion: "8302"
  selfLink: /apis/config.openshift.io/v1/images/cluster
  uid: e34555da-78a9-11e9-b92b-06d6c7da38dc
spec:
  allowedRegistriesForImport: 
    - domainName: quay.io
      insecure: false
  additionalTrustedCA: 
    name: myconfigmap
  registrySources: 
    allowedRegistries:
    - example.com
    - quay.io
    - registry.redhat.io
    - image-registry.openshift-image-registry.svc:5000
    - reg1.io/myrepo/myapp:latest
    insecureRegistries:
    - insecure.com
```
```yaml
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  annotations:
    include.release.openshift.io/ibm-cloud-managed: "true"
    include.release.openshift.io/self-managed-high-availability: "true"
    include.release.openshift.io/single-node-developer: "true"
    release.openshift.io/create-only: "true"
  creationTimestamp: "2023-12-07T05:45:46Z"
  generation: 1
  name: cluster
  ownerReferences:
  - apiVersion: config.openshift.io/v1
    kind: ClusterVersion
    name: version
    uid: 6e335295-dd8a-4c1c-a3ca-137aa7198ddd
  resourceVersion: "36572"
  uid: 16166ebe-6aca-4e67-b776-8a6c4be5a501
spec: {}
status:
  externalRegistryHostnames:
  - default-route-openshift-image-registry.apps.ce0128.tre.nsn-rdnet.net
  internalRegistryHostname: image-registry.openshift-image-registry.svc:5000

```