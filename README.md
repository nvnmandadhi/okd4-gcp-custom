## Prerequisites

1. jq
2. terraform
3. [openshift-install](https://github.com/okd-project/okd/releases)
4. [openshift-client](https://github.com/okd-project/okd/releases)
3. [ccoctl](https://github.com/openshift/cloud-credential-operator/blob/master/docs/ccoctl.md)

## Setup instructions

Set the following variables for Terraform

    base_domain           = "<domain>"
    base_domain_zone_name = "<hyphenated-domain>"
    cluster_project_id    = "<project_id>"
    shared_net_project_id = "<project_id>"
    tf_sa_email           = "<impersonate_sa_email>"

Once the variables are set, run `make`

To destroy the cluster run `make destroy`