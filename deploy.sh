#!/usr/bin/env bash
# AVX512 Workload Deployment Script
# Rhys Oxenham <roxenham@redhat.com>

# Create new project and switch to it
oc new-project monte-carlo
oc project monte-carlo

# Enable user-workload monitoring
oc apply -f user-workloads.yaml

# Deploy avx512 and avx2 workloads
# services, pushgw, and service monitors
oc apply -f 01-avx512.yaml
oc apply -f 02-avx2.yaml

# Deploy Grafana Operator and Instance
oc apply -f grafana-operator.yaml
oc apply -f grafana-instance.yaml

# Sleep whilst Grafana comes up
sleep 60

# Add service account to pull Prometheus data and add datasource
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount
export BEARER_TOKEN=$(oc serviceaccounts get-token grafana-serviceaccount -n monte-carlo)
envsubst < grafana-datasource.yaml | oc apply -f -

# Deploy Grafana dashboard
oc apply -f grafana-dashboard.yaml

# Sleep and wait for route
sleep 20
export GRAFANA_ROUTE=$(oc get route/grafana-route -n monte-carlo | awk '/grafana/ {print $2;}')
echo "Grafana exposed at: https://$GRAFANA_ROUTE/d/qCiDx4mVl/intel-avx512-red-hat-openshift?orgId=1 (admin=redhat/redhat)"
