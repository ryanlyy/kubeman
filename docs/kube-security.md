Kubernetes Security
---

- [Authentication](#authentication)
- [Authorization](#authorization)

https://www.akadia.com/services/ssh_test_certificate.html

# Access to the Kubernetes API
## Client
* kubectl
* client libraries
* REST request

## Object to be authorized
* user
* Service Account

## Stage to access Kubernetes API
* TLS Connection
* Authentication
  * Inputs
    * headers
    * client certificate

  * Authentication Module
    * client certificate
    * password
    * plain tokens
    * bootstrap token
    * JSON Web Tokens (used for service account)


* Authorizition
  * Inputs
    * Username of requester
    * Requested action
    * object affected by the action

The requested is authorized if an existing policy declares that the user has permissions to complete the requested action

* Admission Control
  * software modules that can modify or reject requests.

## AP Server ports
* "localhost" port
  * --insecure-port = 0 can disable this port
* "secure" Port
  * --secure-port=6443
  * uses TLS. Set cert with --tls-cert-file and key with --tls-private-key-file flag
    ```
    --tls-cert-file=/etc/kubernetes/pki/apiserver.crt 
    --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    ```
  * default is port 6443, change with --secure-port flag.
  * default IP is first non-localhost network interface, change with --bind-address flag.
  * request handled by authentication and authorization modules.
  * request handled by admission control module(s).
  * authentication and authorization modules run
  
# Authentication
# Authorization
# Admission Control