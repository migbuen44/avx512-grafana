# Demonstrating AVX512 vs AVX2 on Red Hat OpenShift w/Ansible

**Authors**: [Rhys Oxenham](mailto:roxenham@redhat.com)

This repository aims to demonstrate AVX512 vs AVX2 performance in the [Monte Carlo](https://www.intel.com/content/www/us/en/developer/articles/technical/speed-up-monte-carlo-simulation-with-oneapi.html#gs.dnawzu) simulation (which should result in ~50% perf increase), and how to set it up visually in Red Hat OpenShift.

> *NOTE*: You will need to ensure that you have nodes that support AVX512/AVX2 in your OpenShift cluster, or the workloads will fail to schedule!

The deployment playbook does the following-

* Create a new dedicated OpenShift project "monte-carlo"
* Enable [user-workload monitoring](https://docs.openshift.com/container-platform/4.11/monitoring/enabling-monitoring-for-user-defined-projects.html) in built-in OpenShift monitoring
* Deploy an AVX512 and AVX2 based Monte Carlo simulation pod (with Prometheus Push Gateway)
* Enable ServiceMonitors for the two workload pods to scrape gateways
* Deploy the Grafana Community Operator (v4.7.0) and create an instance
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

To deploy the environment, simply run the following, assuming you have already exported `KUBECONFIG` as an environment variable and have *system:admin* access:

~~~bash
# oc whoami
system:admin

# ansible-playbook deploy.yaml
(...)
~~~

### Clean Up

To clean up all of the resources, simply run the following-

~~~bash
# ansible-playbook cleanup.yaml
(...)
~~~

### Ansible Automation Platform

To integrate with AAP, you need to enable the `kubeconfig` credential type in AAP, by defining a new type with the configurations found in the "aap" directory.

First, the input configuration:

~~~yaml
fields:
  - id: kube_config
    type: string
    label: kubeconfig
    secret: true
    multiline: true
required:
  - kube_config
~~~

Then, the injector format:

~~~yaml
env:
  KUBECONFIG: '{{ tower.filename.kubeconfig }}'
  K8S_AUTH_KUBECONFIG: '{{ tower.filename.kubeconfig }}'
file:
  template.kubeconfig: '{{ kube_config }}'
~~~

Once you have this, you can create new credentials and upload your kubeconfig.

Now you can create a new template for both `deploy` and `cleanup`, referencing this Git repo as the source, and use the "Default Execution Environment".

When you run the deploy playbook, your environment will be deployed in the `monte-carlo` namespace on the cluster your kubeconfig enables access to.
