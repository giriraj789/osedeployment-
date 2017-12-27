!#/bin/bash 
#switch to metrics project
oc project openshift-infra
 
DEPLOYER=/usr/share/openshift/hosted/metrics-deployer.yaml
CASSANDRA_PV_SIZE=10Gi
USE_PERSISTENT_STORAGE=true
MASTER_URL=https://master1.giriaddns.net:8443
METRIC_DURATION=2
HAWKULAR_METRICS_HOSTNAME=hawkular-metrics.master1.giriaddns.net
#IMAGE_PREFIX=docker-enterprise-prod-local.artifactrepository.citigroup.net/cate-citisystems-openshift/
 
# create metrics sa
oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-deployer
secrets:
- name: metrics-deployer
API
 
oadm policy add-role-to-user \
    edit system:serviceaccount:openshift-infra:metrics-deployer
oadm policy add-cluster-role-to-user \
    cluster-reader system:serviceaccount:openshift-infra:heapster
 
oc secrets new metrics-deployer nothing=/dev/null
 
oc create -f - <<PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: metering-volume
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  nfs:
    path: /exports/nfs/metrics
    server: 192.168.124.9
  persistentVolumeReclaimPolicy: Recycle
PV
 
oc process -f $DEPLOYER -v \
CASSANDRA_PV_SIZE=$CASSANDRA_PV_SIZE,USE_PERSISTENT_STORAGE=$USE_PERSISTENT_STORAGE,\
MASTER_URL=$MASTER_URL,METRIC_DURATION=$METRIC_DURATION,HAWKULAR_METRICS_HOSTNAME=$HAWKULAR_METRICS_HOSTNAME,\
REDEPLOY=$REDEPLOY | oc create -f -
 
