sed -i '/swap/d' /etc/fstab
swapoff -a
systemctl disable --now ufw >/dev/null 2>&1

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF


sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

apt install -qq -y kubeadm=1.22.0-00 kubelet=1.22.0-00 kubectl=1.22.0-00 >/dev/null 2>&1

sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1

cat >>/etc/hosts<<EOF
172.16.16.100   controlplane.foo.bar     controlplane
172.16.16.101   node-1.foo.bar    node-1
172.16.16.102   node-2.foo.bar    node-2
EOF

