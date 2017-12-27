oc delete project logging
sleep 30
oadm new-project logging --node-selector=""
oc project logging
 
oc secrets new logging-fluentd nothing=/dev/null
oc secrets new aggregated-logging-fluentd nothing=/dev/null
oc secrets new logging-deployer nothing=/dev/null
 
oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aggregated-logging-fluentd
secrets:
- name: aggregated-logging-fluentd
API
 
oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
  name: logging-deployer
secrets:
- name: logging-deployer
API
 
oc policy add-role-to-user edit --serviceaccount logging-deployer
oadm policy add-scc-to-user  \
    privileged system:serviceaccount:logging:aggregated-logging-fluentd
oadm policy add-cluster-role-to-user cluster-reader \
    system:serviceaccount:logging:aggregated-logging-fluentd
 
oc create -f /var/tmp/logging-fluentd-dc
 
sleep 10
 
