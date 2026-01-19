#!/bin/bash
set -euxo pipefail

LOG=/var/log/user-data.log
exec > >(tee -a $LOG) 2>&1

echo "===== System update ====="
dnf update -y

echo "===== Install base tools ====="
dnf install -y git wget

echo "===== Install Java 21 (Amazon Corretto) ====="
dnf install -y java-21-amazon-corretto

java --version

echo "===== Add Jenkins repo ====="
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/repodata/repomd.xml.key

echo "===== Install Jenkins ====="
dnf install -y jenkins

echo "===== Install Docker ====="
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker jenkins

echo "===== WAIT for systemd to settle ====="
sleep 30
systemctl daemon-reexec
systemctl daemon-reload
mount -o remount,size=2G /tmp

echo "===== Enable and start Jenkins ====="
systemctl enable jenkins
systemctl restart jenkins

echo "===== Jenkins status ====="
systemctl status jenkins --no-pager
docker --version
systemctl status docker --no-pager


