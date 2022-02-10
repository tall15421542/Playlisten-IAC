# Playlisten Infrastructure As Code Documentation

## Prerequisites
1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
2. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
3. The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
4. [An AWS account](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all).
5. Your AWS credentials. You can [create a new Access Key on this page](https://console.aws.amazon.com/iam/home?#/security_credentials).

Configure the AWS CLI from your terminal. Follow the prompts to input your AWS Access Key ID and Secret Access Key.
```
$ aws configure
```
6. [Create AWS Key pairs](https://console.aws.amazon.com/ec2/v2/home?#KeyPairs:sort=key-pair-id) named ``playlisten``, and download the private key file to the destination ``~/.ssh/playlisten.pem``.
7. Allocate a [Elastic Ip Address](https://console.aws.amazon.com/ec2/v2/home?#Addresses:).
8. Register the domain name ``playlisten.app``.
---
**NOTE**

``playlisten.app`` was hard-coded into the IAC because of the SSL certificate From the CA. 

---
9. Register DNS record with ``Elastic IP``allocated from step 7.

|       Host Name      |  Type  |    TTL   |      Data      |
|:--------------------:|:------:|:--------:|:--------------:|
|    playlisten.app    |   Ａ   |  1 hour  |  [Elastic IP]  |
|  www.playlisten.app  |    A   |  1 hour  |  [Elastic IP]  |

10. Edit terraform/elastic_ip_var.tf ``registered_domain_dns_addr`` variable.
```
variable "registered_domain_dns_addr" {
  default = "[Allocated Elastic IP]"
  description = "google dns playlisten.app record addr"
}
```
11. Get permission from Ming-Hung Tsai to [share latest playlisten RDS snapshot with your AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/rds-snapshots-share-account/).
## How to deploy playlisten.app
```
sh deploy.sh
```

## How to destroy the aws instance to save money!!!
```
sh destroy.sh
```

## To do
1. Use terraform output variable ``module.db.db_instance_endpoint`` to update ``env.db`` file in the repo [Playlisten-deploy](https://github.com/tall15421542/Playlisten-deploy/blob/main/PlayListen-backend/env.db) to prevent aws allocates RDS in a different endpoint.
2. Make domain name ``playlisten.app`` configurable
    * Automate the process of cerbot SSL certificate registration and put it in the webserver container
    * Use variable to replace hard-coded "playlisten.app" in ``ansible/inventory/hosts``, ``ansible/site.yml``. 
