# Homelab

This is an infrastructure-as-code (IaC) repository for my homelab. 

I make use of Ansible, Shell Scripts, and Podman to automate deployment of services. I am in the process of adding Kubernetes manifests to deploy services to my cluster using Helm charts.

## Services

- web-proxy     # Cloudflared
- web-Portal    # Nginx, App
- web-pages     # Nginx (with Logrotate), Static Content
- web-api       # Krakend, RabbitMQ, Valkey, Garage
- web-ci        # Woodpecker, Woodpecker Runner
- web-git       # Gitea, Gitea Runner
- web-metrics   # Grafana, Prometheus
- web-db        # PostgreSQL

### Web-Proxy

The web-proxy service is a Cloudflared instance that tunnels traffic to my homelab. This allows me to expose services that are running on my homelab to the internet without having to open ports on my router. The documentation for the container image is a bit lacking. The proxy service is managed via the `one.dash.cloudflare` dashboard.

### Web-Portal

The web-portal service is a web-app being served by Nginx. The app is a client portal and its backend is written in Go and Python.

### Web-Pages

The web-pages service is a collection of static websites being served by Nginx. The websites are written in HTML, CSS, and JavaScript. The repo has some placeholder pages in place of the actual content.

### Web-API

The web-api service is the `krakend` API Gateway that exposes access to `garage`, `rabbitmq`, and `valkey`. The purpose of this gateway is to provide an authentication, authorization, and rate-limiting layer for the services that it fronts.

### Web-CI

The web-ci service is a `woodpecker-ci` instance and `woodpecker-runner`. The service is a private CI/CD pipeline that is used to build, test, and deploy the repositories hosted on `gitea` to machines in my homelab.

### Web-Git

The web-git service is a `gitea` instance and `gitea-runner`. The service is a private code forge that acts as version control, issue tracking, project manager, artifact registry, and CI/CD for my homelab. The `gitea-runner` service is used to run CI/CD pipelines for the repositories hosted on `gitea`.

### Web-Metrics

The web-metrics service is a `grafana` instance that is backed by `prometheus`. The service is used to monitor the health of the services and hardware running in my homelab.

### Web-DB

The web-db service is a PostgreSQL database that backs `grafana`, `gitea`, `woodpecker-ci`, and the portal.

## Deploying Services

The `web-services` directory contains a collection of services that I run out of my homelab. Each service is a subdirectory that contains a `docker-compose.yml` file and any other necessary configuration files. These services can be deployed using ansible or a one-liner.

You will need to set your environment by copying the `.env.example` file to `.env` and updating the variables to match your environment then running `source .env` in the root of the repository. You can use `getenv` couple with a variable name to get the value of a variable from the `.env` file to check that things are set correctly.

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
