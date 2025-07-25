# terraform-nutanix-ansible

[![GitHub](https://img.shields.io/badge/GitHub-NgYaoDong%2Fterraform--nutanix--ansible-blue?logo=github)](https://github.com/NgYaoDong/terraform-nutanix-ansible)

Automate deployment of Strongswan VPN clients and gateways on Nutanix using Terraform and Ansible. This project provisions VMs, configures networking, and sets up VPN connectivity with post-deployment scripts.

---

## Features

- Deploy multiple client and gateway VMs on Nutanix clusters
- Assign static IPs to all VMs
- Automated Strongswan VPN setup via provisioning scripts
- Custom shell scripts for post-deployment configuration

---

## Prerequisites

- Nutanix Prism Element endpoint and credentials
- Terraform >= 1.0
- Nutanix Terraform Provider (v2.2.0 recommended)
- Ansible (for post-deployment provisioning)
- SSH access to VMs

Additional setup for VMs:

Install these services in the VMs first, export them as an OVF/OVA file, then upload the .vmdk of these VMs to Nutanix Prism Element under Image Configuration.
Note: Ensure that your VMs have the correct number of network adapters and that they are all set to `bridged` before exporting them.

- Deployment/CA VM: Terraform, Nutanix provider for Terraform, sftp server (openssh-server), strongswan pki, inotify-tools, python3, pip, ansible (installed using pip), sshpass
  
  - Deployment/CA VM is to be set up manually in Nutanix first.

- VPN VMs: strongswan, bash, sshpass, sftp client (openssh-client), python3

---

## Quickstart

### 1. Clone the repository into the Deployment/CA VM

```bash
git clone https://github.com/NgYaoDong/terraform-nutanix-ansible.git
cd terraform-nutanix-ansible
```

### 2. Set up the Certificate Authority (CA)

See [`scripts/ca/README.md`](scripts/ca/README.md) for instructions.

### 3. Configure variables

Create a `terraform.tfvars` file with your Nutanix details and desired VM counts:

```hcl
nutanix_endpoint             = "<your-nutanix-endpoint>" # Prism Element endpoint
nutanix_username             = "<your-nutanix-username>" # Prism Element username
nutanix_password             = "<your-nutanix-password>" # Prism Element password
nutanix_cluster_name         = "strongswan-terraform"    # Name of the Nutanix cluster
nutanix_internet_subnet_name = "Internet"                # Name of the internet subnet
nutanix_intranet_subnet_name = "Intranet"                # Name of the intranet subnet
nutanix_image_name           = "strongswan-alpine"       # Name of the VM image to use
num_clients                  = 2                         # Number of client VMs to create
num_gateways                 = 2                         # Number of gateway VMs to create
```

Edit `client_ips`, `gateway_internet_ips`, and `gateway_intranet_ips` in [`locals.tf`](locals.tf) to set your IP ranges.

### 4. Prepare deployment scripts

- [`setup.sh`](scripts/entity/setup.sh) is copied and executed on each VM for Strongswan and certificate setup.
- Create `env.sh` in [`scripts/entity/`](scripts/entity/) with required environment variables:

```bash
# Environment variables for setup.sh
deployment_username="<your-ca-vm-username>"
ca_vm_ip="<your-ca-vm-endpoint>"

local_csr_path="/tmp/${HOSTNAME}Req.pem"
remote_csr_path="/tmp/csr_inbox/${HOSTNAME}Req.pem"

local_entity_crt_path="/etc/swanctl/x509/${HOSTNAME}Cert.pem"
remote_entity_crt_path="/tmp/signed/${HOSTNAME}Cert.pem"

local_ca_crt_path="/etc/swanctl/x509ca/caCert.pem"
remote_ca_crt_path="/tmp/ca/caCert.pem"

ssh_key_path="$HOME/.ssh/id_rsa_entity"
ca_vm_password="<your-ca-vm-password>"
```

### 5. Deploy VMs with Terraform

```bash
terraform init
terraform apply
```

### 6. Provision VMs with Ansible

After VMs are created, run:

```bash
bash run_ansible.sh
```

### 7. Post-deployment

- Access VM consoles in Nutanix Prism Element (username: `root`, password: `password`)
- Strongswan VPN is auto-configured via scripts

---

## Variables

See [`variables.tf`](variables.tf) for all configurable variables:

- `nutanix_endpoint`, `nutanix_username`, `nutanix_password`
- `nutanix_cluster_name`, `nutanix_internet_subnet_name`, `nutanix_intranet_subnet_name`, `nutanix_image_name`
- `num_clients`, `num_gateways`
- `ssh_username`, `ssh_password`

---

## File Structure

- [`providers.tf`](providers.tf) – Provider configuration
- [`data.tf`](data.tf) – Data sources for cluster, subnets, and image
- [`locals.tf`](locals.tf) – Local values for dynamic resource creation
- [`vms.tf`](vms.tf) – VM resource definitions
- [`variables.tf`](variables.tf) – Input variables
- [`terraform.tfvars`](terraform.tfvars) – User-specific variable values (create this file)
- [`ansible/`](ansible/) – Ansible configuration files
  - [`provision.yml`](ansible/provision.yml) – Ansible playbook for VM provisioning
  - [`dynamic_inventory.py`](ansible/dynamic_inventory.py) – Example custom inventory script
- [`scripts/`](scripts/) – Shell scripts for VM provisioning
  - [`README.md`](scripts/README.md)
  - [`ca/`](scripts/ca/) – Certificate Authority scripts
    - [`README.md`](scripts/ca/README.md)
    - [`ca_csr_watcher.sh`](scripts/ca/ca_csr_watcher.sh)
    - [`genca.sh`](scripts/ca/genca.sh)
  - [`entity/`](scripts/entity/) – Entity (client/gateway) setup scripts
    - [`env.sh`](scripts/entity/env.sh) – Environment variables (create this file)
    - [`gencerts.sh`](scripts/entity/gencerts.sh)
    - [`setup.sh`](scripts/entity/setup.sh)
- [`misc/`](misc/) – Miscellaneous configuration and reference files
  - [`conf/`](misc/conf/)
    - [`README.md`](misc/conf/README.md)
    - [`client1/swanctl.conf`](misc/conf/client1/swanctl.conf)
    - [`client2/swanctl.conf`](misc/conf/client2/swanctl.conf)
    - [`client3/swanctl.conf`](misc/conf/client3/swanctl.conf)
    - [`gateway1/swanctl.conf`](misc/conf/gateway1/swanctl.conf)
    - [`gateway2/swanctl.conf`](misc/conf/gateway2/swanctl.conf)
  - [`ref/`](misc/ref/)
    - [`main.tf`](misc/ref/main.tf)
    - [`README.md`](misc/ref/README.md)

---

## Notes

- Sensitive data (passwords, etc.) should not be committed. See [`.gitignore`](.gitignore).
- [`setup.sh`](scripts/entity/setup.sh) expects an `env.sh` file with required environment variables.
- Create your own `terraform.tfvars` and `env.sh` files (excluded from version control).

---

## References

- See [`scripts/README.md`](scripts/README.md) and [`misc/ref/README.md`](misc/ref/README.md) for more details.
