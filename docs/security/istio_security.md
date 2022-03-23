ISTIO Security 
---



# Plug in CA Certificates

By default the Istio CA generates **a self-signed root certificate** and key and uses them to sign the workload certificates. To protect the root CA key, you should use a **root CA** which runs on a secure machine offline, and use the root CA to issue **intermediate certificates** to the Istio CAs that run in each cluster. An Istio CA can sign workload certificates using the administrator-specified certificate and key, and distribute an administrator-specified root certificate to the workloads as the root of trust.


## Self signed CA
## Using Kubernetes CA
## Using Custom CA
