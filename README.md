# Homelab

This is an infrastructure-as-code (IaC) repository for my homelab. 

I make use of Ansible, Shell Scripts, and Podman to automate deployment of services. I am in the process of adding Kubernetes manifests to deploy services to my cluster using Helm charts.

### Services

- web-proxy     # Cloudflared
- web-apps      # Nginx, Python, Go
- web-pages     # Nginx, Static Content
- web-api       # Krakend, RabbitMQ, Valkey, Garage
- web-ci        # Woodpecker, Woodpecker Runner
- web-git       # Gitea, Gitea Runner
- web-metrics   # Grafana, Prometheus
- web-db        # PostgreSQL

## Deploying Services

The `web-services` directory contains a collection of services that I run out of my homelab. Each service is a subdirectory that contains a `docker-compose.yml` file and any other necessary configuration files. These services can be deployed using ansible or a one-liner.

```bash
# Example: deploy all web services to a specific host
# Some services may require additional configuration like web-apps and web-pages
ansible-playbook -i ansible/inventory web-services.yml --tags install --limit e1
```

```bash
# Example: deploy a specific service to a specific host
ansible-playbook -i ansible/inventory web-services.yml --tags web-proxy --limit e1
```

```bash
# Deploy a all services without Ansible
# Requires a Debian-based OS, curl, and bash
# All the usual caveats about piping to bash apply
curl -sL https://raw.githubusercontent.com/m-spangenberg/homelab/main/web-services/install.sh | bash
```
