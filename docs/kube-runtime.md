This artical is used to summary all changes when docker is replaced by containerd, cri-o and podman
------------------
- [Deployment](#deployment)
- [Configuraiton](#configuraiton)
  - [Runtime Class](#runtime-class)
- [Operation and Debugging](#operation-and-debugging)
  - [Command Comparision](#command-comparision)
  - [Debugging](#debugging)
- [Application](#application)

# Deployment

| Deployment | Docker | containerd | CRIO | poman |
|----------|----------|----------|----------|----------| 
|A | B | C | D | E |


# Configuraiton
## Runtime Class
Kubernetes v1.20 [stable]

Multiple runtime can be used by kebernetes
https://kubernetes.io/zh/docs/concepts/containers/runtime-class/

**Motivation**

You can set a different RuntimeClass between different Pods to provide **a balance of performance versus security**. For example, if part of your workload deserves a high level of information security assurance, you might choose to schedule those Pods so that they run in a container runtime that uses hardware virtualization. You'd then benefit from the extra isolation of the alternative runtime, at the expense of some additional overhead.

You can also use RuntimeClass to run different Pods with the same container runtime but with different settings.



# Operation and Debugging
## Command Comparision

| Catelog | Docker Command(docker) | Containerd Command(crictl) | CRIO Command | podman |
|----------- |----------- |----------- |----------- |----------- |
| Container|attach |attach |D | attach |
|N/A|N/A|N/A|N/A|auto-update |
| Image|build |N/A |D | build |
| Container|commit |N/A |D | commit |
| system |N/A|completion|D| E |
| Container|cp |N/A |D | cp |
| N/A|N/A|config|D| E |
| Container|create |create |D | create |
| Container|diff |N/A |D | diff |
| system|events |N/A |D | events |
| Container|exec |exec |D | exec |
| Container|export |N/A |D | export |
|N/A|N/A|N/A|N/A|generate |
|N/A|N/A|N/A|N/A|healthcheck |
| Image|history |N/A |D | history |
| Image|images |images |D | images |
| Image|import |N/A |D | import |
| system|info |info |D | info |
|N/A|N/A|N/A|N/A|init |
| Container|inspect |inspect/inspecti/inspectp |D | inspect |
| Container|kill |N/A |D | kill |
| Image|load |N/A |D | load |
| Image|login |N/A |D | login |
| Image|logout |N/A |D | logout |
| Container|logs |logs |D | logs |
|N/A|N/A|N/A|N/A|manifest |
|N/A|N/A|N/A|N/A|mount |
| Container|pause|C|D|pause|
|N/A|N/A|N/A|N/A|play |
|N/A|N/A|N/A|N/A|pod |
| Container|port |port-forward |D | port |
| Container|ps |ps/pods |D | ps |
| Image|pull |pull |D | pull |
| Image|push |N/A |D | push |
| Container|rename |N/A |D | rename |
| Container|restart |N/A |D | restart |
| Container|rm |rm/rmp |D | rm |
| Image|rmi |rmi |D | rmi |
| Container|run |runp |D | run |
| Image|save |N/A |D | save |
| Image|search |N/A |D | search |
|N/A|N/A|N/A|N/A|secret |
| Container|start |start |D | start |
| Container|stats |stats |D | stats |
| Container|stop |stop/stopp |D | stop |
|N/A|N/A|N/A|N/A|system |
| Image|tag |N/A |D | tag |
| Container|top |N/A |D | top |
|N/A|N/A|N/A|N/A|unmount |
| Container|unpause |N/A |D | unpause |
|N/A|N/A|N/A|N/A|unshare |
| Container|update |update |D | E |
| system|version |version |D | E |
|N/A|N/A|N/A|N/A|volume |
| Container|wait |N/A |D | wait |

##  Debugging
| Debugging | Docker | containerd | crio | podman | 
|--------|--------|--------|--------|--------|

# Application 
| Impact | Docker | containerd | crio | podman | 
|--------|--------|--------|--------|--------|

