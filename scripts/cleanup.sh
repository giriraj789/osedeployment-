!#/bin/bash
yum -y remove openshift openshift-* etcd docker
rm -rf /etc/origin /var/lib/openshift /etc/etcd \
/var/lib/etcd /etc/sysconfig/atomic-openshift*
/etc/sysconfig/docker* \
/root/.kube/config /etc/ansible/facts.d /usr/share/openshift
