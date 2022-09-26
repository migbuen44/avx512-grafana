# Demonstrating AVX512 vs AVX2 on Red Hat OpenShift

**Authors**: [Rhys Oxenham](mailto:roxenham@redhat.com)

This repository aims to demonstrate AVX512 vs AVX2 performance in the [Monte Carlo](https://www.intel.com/content/www/us/en/developer/articles/technical/speed-up-monte-carlo-simulation-with-oneapi.html#gs.dnawzu) simulation (which should result in ~50% perf increase), and how to set it up visually in Red Hat OpenShift.

> *NOTE*: You will need to ensure that you have nodes that support AVX512/AVX2 in your OpenShift cluster, or the workloads will fail to schedule!

The deployment script does the following-

* Create a new dedicated OpenShift project "monte-carlo"
* Enable [user-workload monitoring](https://docs.openshift.com/container-platform/4.11/monitoring/enabling-monitoring-for-user-defined-projects.html) in built-in OpenShift monitoring
* Deploy an AVX512 and AVX2 based Monte Carlo simulation pod (with Prometheus Push Gateway)
* Enable ServiceMonitors for the two workload pods to scrape gateways
* Deploy the Grafana Community Operator (v4.6.0) and create an instance
* Create a Grafana service account to have access to Prometheus/Thanos data (built-in)
* Add Grafana Datasource for Prometheus/Thanos data (built-in)
* Deploy a Custom Grafana Dashboard to show "time_elapsed" between AVX2 and AVX512
* Show the Grafana Dashboard Route to the user

> *NOTE*: Make sure that you've deployed the [NodeFeatureDiscovery](https://docs.openshift.com/container-platform/4.11/hardware_enablement/psap-node-feature-discovery-operator.html) operator, and an equivalent instance, as we tag the workload pods to nodes that support required features:

~~~yaml
spec:
  restartPolicy: Never
  nodeSelector:
    feature.node.kubernetes.io/cpu-cpuid.AVX512BW: "true" # requires NFD
~~~

### Deployment

To deploy the environment, simply run the following, assuming you have already configured your OpenShift client and have *system:admin* access:

~~~bash
# oc whoami
system:admin

# ./deploy.sh
(...)
~~~

### Clean Up

To clean up all of the resources, simply run the following-

~~~bash
# ./cleanup.sh
(...)
~~~
