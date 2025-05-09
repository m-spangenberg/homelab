# Homelab

This is an infrastructure-as-code (IaC) repository for my homelab.

## Ansible

The `ansible` directory contains a collection of Ansible playbooks and roles that are used to deploy and manage the services in my homelab. I don't use it extensively because my homelab is small and I rarely have need for scratch deploys.

`services.yml` deploys containerized services using Podman.
`cluster.yml` is used to deploy a cluster on a set of hosts.
`maintenance.yml` runs general maintenance tasks on machines in the lab.

## Services

At the moment all containerized services in my homelab are deployed using Podman. Containers have resource limits on them so they all fit on a single host with 16GB of RAM and 8 CPU cores.

- dev-proxy     # Cloudflared                             OK
- dev-vault     # HashiCorp Vault                         NOK
- dev-ssh       # SSH Bastion                             NOK
- dev-portal    # Nginx, App                              OK
- dev-automate  # N8N (Workflow Automation)               NOK
- dev-push      # Ntfy (Push Notifications)               NOK
- dev-backend   # Nginx (with Logrotate), Pocketbase      OK
- dev-pages     # Nginx (with Logrotate), Static Content  OK
- dev-api       # Krakend, RabbitMQ, Valkey, Garage       OK
- dev-git       # Gitea, Gitea Runner                     OK
- dev-metrics   # Grafana, Prometheus                     OK
- dev-db        # PostgreSQL                              OK
- dev-dns       # Blocky DNS proxy and Ad-blocker         OK

## Deploying Services

The `dev-services` directory contains a collection of services that I run out of my homelab. Each service is a subdirectory that contains a `docker-compose.yml` file and any other necessary configuration files. These services can be deployed using ansible or a one-liner.

You will need to set your environment by copying the `.env.example` file to `.env` and updating the variables to match your environment then running `source .env` in the root of the repository. You can use `getenv` couple with a variable name to get the value of a variable from the `.env` file to check that things are set correctly.

```bash
# Example: deploy all dev services to a specific host
# Some services may require additional configuration like dev-apps and dev-pages
ansible-playbook -i ansible/inventory dev-services.yml --tags install --limit e1
```

```bash
# Example: deploy a specific service to a specific host
ansible-playbook -i ansible/inventory dev-services.yml --tags dev-proxy --limit e1
```

```bash
# Deploy all services without Ansible
# Requires a Debian-based OS, curl, and bash
# All the usual caveats about piping to bash apply
curl -sL https://raw.githubusercontent.com/m-spangenberg/homelab/main/dev-services/install.sh | bash
```
