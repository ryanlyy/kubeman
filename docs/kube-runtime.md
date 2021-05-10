This artical is used to summary all changes when docker is replaced by containerd, cri-o and podman
------------------
- [Deployment](#deployment)
- [Configuraiton](#configuraiton)
  - [Runtime Class](#runtime-class)
- [Operation and Debugging](#operation-and-debugging)
  - [Command Comparision](#command-comparision)
  - [](#)
- [Application](#application)

# Deployment
# Configuraiton
## Runtime Class
Multiple runtime can be used by kebernetes
https://kubernetes.io/zh/docs/concepts/containers/runtime-class/

# Operation and Debugging
## Command Comparision

| Catelog | Docker Command(docker) | Containerd Command(crictl) | CRIO Command | podman |
|----------- |----------- |----------- |----------- |----------- |
| Container|attach |attach |D | E |
| Image|build |N/A |D | E |
| Container|commit |N/A |D | E |
| system |N/A|completion|D| E |
| Container|cp |N/A |D | E |
| N/A|N/A|config|D| E |
| Container|create |create |D | E |
| Container|diff |N/A |D | E |
| system|events |N/A |D | E |
| Container|exec |exec |D | E |
| Container|export |N/A |D | E |
| Image|history |N/A |D | E |
| Image|images |images |D | E |
| Image|import |N/A |D | E |
| system|info |info |D | E |
| Container|inspect |inspect/inspecti/inspectp |D | E |
| Container|kill |N/A |D | E |
| Image|load |N/A |D | E |
| Image|login |N/A |D | E |
| Image|logout |N/A |D | E |
| Container|logs |logs |D | E |
| Container|port |port-forward |D | E |
| Container|ps |ps/pods |D | E |
| Image|pull |pull |D | E |
| Image|push |N/A |D | E |
| Container|rename |N/A |D | E |
| Container|restart |N/A |D | E |
| Container|rm |rm/rmp |D | E |
| Image|rmi |rmi |D | E |
| Container|run |runp |D | E |
| Image|save |N/A |D | E |
| Image|search |N/A |D | E |
| Container|start |start |D | E |
| Container|stats |stats |D | E |
| Container|stop |stop/stopp |D | E |
| Image|tag |N/A |D | E |
| Container|top |N/A |D | E |
| Container|unpause |N/A |D | E |
| Container|update |update |D | E |
| system|version |version |D | E |
| Container|wait |N/A |D | E |


## 
# Application 
