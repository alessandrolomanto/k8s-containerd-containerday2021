### Prerequisites

To follow Vagrant tutorial, you need:
- **VirtualBox** - Follow installation guide on https://www.virtualbox.org/wiki/Downloads to install VirtualBox
- **Vagrant** - Follow installation guide on https://www.vagrantup.com/docs/installation/index.html to install Vagrant

### Step 1 - Start Kubernetes Vagrant cluster

```bash
make vagrant-start
```

### Step 2 - Try Kubernetes Cluster

```bash
vagrant ssh master
```
```bash
kubectl get all --all-namespaces
```
## Step Destroy - Delete Kubernetes Cluster and Machine

```bash
make vagrant-destroy
```
---
# ***View kubelet log for dockershim deprecation***
- Open `var/log/syslog`
```bash
cat var/log/syslog | grep dockershim 
```
---
# ***Configure containerd as container runtime***

## ***Drain node because of scheduler***
```bash
kubectl drain node-2 --ignore-daemonsets
```
## ***SSH to node***
- Password `kubeadmin`
```bash
ssh root@node-2
```
## ***Stop kubelet and docker services***
```bash
systemctl stop kubelet
systemctl stop docker
```
## ***Remove Docker software***
```bash
apt remove --purge docker-ce docker-ce-cli
```
## ***Make sure that containerd configuration allows disabled_plugin***
- Comment `#disabled_plugins=["cri"]`
```bash
vi /etc/containerd/config.toml 
```
## ***Restart containerd***
```bash
systemctl restart containerd
```
## ***Change kubelet configuration***
- Add `--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock`
```bash
vi /var/lib/kubelet/kubeadm-flags.env
```
## ***Start kubelet and return controlplane***
```bash
systemctl start kubelet
exit
```
## ***Make node-2 avaible and try new deployment***
```bash
kubectl uncordon node-2
kubectl create deploy nginx --image=nginx --replicas=4
```
- **`kubectl get pods -o wide`** - To see that the pods are running in both nodes