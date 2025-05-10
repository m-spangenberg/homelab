# Homelab

This is an infrastructure-as-code (IaC) repository for my homelab.

> [!WARNING]
> The code in this repository is set up for my needs and hardware. You will have to make changes to it to suit your needs if you choose to use any of the scripts.

## Services

At the moment services in my homelab are containerized and deployed using Podman. Containers have resource limits on them so they all fit on a single host with 16GB of RAM and 8 CPU cores.

```bash
- dev-proxy     # Cloudflared                             OK
- dev-vault     # HashiCorp Vault                         NOK
- dev-ssh       # SSH Bastion                             NOK
- dev-portal    # Nginx, App                              OK
- dev-automate  # N8N (Workflow Automation)               NOK
- dev-notify    # Ntfy (Pub-Sub Notifications)            NOK
- dev-push      # Apprise (Push Notifications)            NOK
- dev-backend   # Nginx (with Logrotate), Pocketbase      OK
- dev-pages     # Nginx (with Logrotate), Static Content  OK
- dev-api       # Krakend, RabbitMQ, Valkey, Garage S3    OK
- dev-git       # Gitea, Gitea Runner                     OK
- dev-metrics   # Grafana, Prometheus, Alertmanager       NOK
- dev-logs      # Loki, Alloy, Pyroscope                  NOK
- dev-backup    # Restic, Rclone, syncthing               NOK
- dev-mesh      # Istio                                   NOK
- dev-overlay   # Tailscale                               NOK
- dev-identity  # Authentic                               NOK
- dev-db        # PostgreSQL, Mongo                       NOK
- dev-dns       # Blocky DNS proxy and Ad-blocker         OK
```

### Service Interactions

#### External Access Layer:

> **TODO** 
> add tailscale and bastion docker-compose.

- dev-proxy (Cloudflared) handles tunneling for external access.
- dev-overlay (Tailscale) provides a mesh VPN.
- dev-ssh serves as a SSH bastion host.
- dev-dns (Blocky) manages DNS queries.

#### Identity & Access Layer:

> **TODO** 
> add authentic and vault docker-compose.

- dev-identity (Authentic) manages authentication and authorization.
- dev-vault (HashiCorp Vault) handles secrets management.

#### Application Layer:

- dev-portal, dev-pages, and dev-backend serve web applications and static content via Nginx.
- dev-api (Krakend) acts as the API gateway, interfacing with RabbitMQ, Valkey, and Garage S3 for messaging, caching, and object storage.

#### Automation & DevOps Layer:

> **TODO** 
> Test dev-automate docker-compose. Add istio docker-compose.

- dev-automate (N8N) orchestrates workflows and automation.
- dev-git (Gitea) hosts Git repositories and runners for CI/CD.
- dev-mesh (Istio) manages service mesh capabilities.

#### Observability & Backup Layer:

> **TODO** 
> Add Alertmanager to dev-metrics docker-compose. Create dev-logs and dev-backup.

- dev-metrics (Grafana, Prometheus, Alertmanager) monitors system metrics and alerts.
- dev-logs (Loki, Alloy, Pyroscope) handles logging and performance profiling.
- dev-backup (Restic, Rclone, Syncthing) manages backups of data.

#### Notification Layer:

> **TODO** 
> Test dev-notify and add apprise to dev-push docker-compose.

- dev-notify (Ntfy) and dev-push (Apprise) handle notifications and alerts.

## Deploying Services

The `dev-services` directory contains a collection of services that I run out of my homelab. Each service is a subdirectory that contains a `docker-compose.yml` file and any other necessary configuration files. These services can be deployed individually or at once using Ansible.

The `ansible` directory contains a collection of Ansible playbooks and roles that are used to deploy and manage the services. I don't use it extensively because my homelab is small and I rarely have need for scratch deploys.

`services.yml` deploys containerized services using Podman.
`cluster.yml` is used to deploy a cluster on a set of hosts.
`maintenance.yml` runs general maintenance tasks on machines in the lab.

The environment variables need to be set by copying the `.env.example` file to `.env` and updating the variables. Running `source .env` in the root of the repository will make those variables available (this is temporary). You can use `getenv` coupled with a variable name to get the value of a variable from the `.env` file to check that things are set correctly.

```bash
# Example: deploy all dev services to a specific host
# Some services may require additional configuration like dev-apps and dev-pages
ansible-playbook -i ansible/inventory dev-services.yml --tags install --limit e1
```

```bash
# Example: deploy a specific service to a specific host
ansible-playbook -i ansible/inventory dev-services.yml --tags dev-proxy --limit e1
```

> [!CAUTION]
> All the usual caveats about piping to bash apply. This is a script I wrote and use in my homelab. It is not intended for general use and should be reviewed and modified if you intend to test it.

```bash
# Deploy all services without Ansible on a Debian-based OS with curl and bash available
curl -sL https://raw.githubusercontent.com/m-spangenberg/homelab/main/dev-services/install.sh | bash
```
