Podman
---

https://github.com/containers/podman

Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. 

- [Installation](#installation)
  - [CNI Plugin Example](#cni-plugin-example)
- [Configuration](#configuration)
  - [Configure Contents](#configure-contents)
  - [Proxy](#proxy)
- [Unix Socket](#unix-socket)
- [Networking](#networking)

# Installation
https://podman.io/getting-started/installation

```
dnf -y module disable container-tools
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
dnf -y --refresh install podman
```

## CNI Plugin Example
```
{
  "cniVersion": "0.4.0",
  "name": "podman",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni-podman0",
      "isGateway": true,
      "ipMasq": true,
      "hairpinMode": true,
      "ipam": {
        "type": "host-local",
        "routes": [{ "dst": "0.0.0.0/0" }],
        "ranges": [
          [
            {
              "subnet": "10.88.0.0/16",
              "gateway": "10.88.0.1"
            }
          ]
        ]
      }
    },
    {
      "type": "portmap",
      "capabilities": {
        "portMappings": true
      }
    },
    {
      "type": "firewall"
    },
    {
      "type": "tuning"
    }
  ]
}
```

# Configuration
* /usr/share/containers/
* /etc/containers/

## Configure Contents
* /etc/containers/registries.conf
  ```
  # Registries that do not use TLS when pulling images or uses self-signed
  # certificates.
  [registries.insecure]
  registries = ['registry.access.redhat.com', 'registry.redhat.io', 'docker.io']
  ```

* /usr/share/containers/mounts.conf
  
  The mounts.conf files specify volume mount directories that are automatically mounted inside containers when executing the podman run or podman build commands. Container process can then use this content. The volume mount content does not get committed to the final image.

  ```
  [root@foss-ssc-6 containers]# cat /usr/share/containers/mounts.conf
  /usr/share/rhel/secrets:/run/secrets
  [root@foss-ssc-6 containers]#
  ```
  
* /usr/share/containers/seccomp.json
  contains the whitelist of seccomp rules to be allowed inside of containers.

* /etc/containers/policy.json
  
## Proxy
podman reads the environment variables for HTTP_PROXY information. HTTP_PROXY information should be configured as an environment variable for user running as podman or can be configured under /etc/profile.

Example in /etc/profile.d/http_proxy.sh
```
export HTTP_PROXY=http://192.168.0.1:3128
export HTTPS_PROXY=http://192.168.0.1:3128
```

# Unix Socket

* Verify socket listening
  ```
  curl -H "Content-Type: application/json" --unix-socket /run/podman/podman.sock http://localhost/_ping
  ```

# Networking
