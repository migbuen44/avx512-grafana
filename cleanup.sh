#!/usr/bin/env bash
# AVX512 Workload Clean-up Script
# Rhys Oxenham <roxenham@redhat.com>

# Make sure we're in the right project
oc project monte-carlo

# Delete avx512 and avx2 workloads
# services, pushgw, and service monitors
oc delete -f 01-avx512.yaml
oc delete -f 02-avx2.yaml

# Delete Grafana Operator and Instances
oc delete -f grafana-datasource.yaml
oc delete -f grafana-dashboard.yaml
oc delete -f grafana-instance.yaml
oc delete -f grafana-operator.yaml
oc delete csv/grafana-operator.v4.5.1
