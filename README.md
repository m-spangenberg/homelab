# Homelab

![Linting](https://img.shields.io/github/actions/workflow/status/m-spangenberg/homelab/validate.yml?branch=main&label=lint&style=flat-square)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat-square&logo=postgresql&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=flat-square&logo=apachekafka&logoColor=white)
![Cassandra](https://img.shields.io/badge/Cassandra-1287B1?style=flat-square&logo=apachecassandra&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=flat-square&logo=rabbitmq&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat-square&logo=redis&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-0099FF?style=flat-square&logo=traefik&logoColor=white)
![cert-manager](https://img.shields.io/badge/cert--manager-000?style=flat-square&logo=cert--manager&logoColor=white)
![Strapi](https://img.shields.io/badge/Strapi-000?style=flat-square&logo=strapi&logoColor=white)
![PocketBase](https://img.shields.io/badge/PocketBase-000?style=flat-square&logo=pocketbase&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-000?style=flat-square&logo=gitea&logoColor=white)
![n8n](https://img.shields.io/badge/n8n-000?style=flat-square&logo=n8n&logoColor=white)
![ntfy](https://img.shields.io/badge/ntfy-000?style=flat-square&logo=ntfy&logoColor=white)
![Longhorn](https://img.shields.io/badge/Storage-Longhorn-orange?style=flat-square)
![Calico](https://img.shields.io/badge/CNI-Calico-green?style=flat-square)
![MetalLB](https://img.shields.io/badge/L2%20LB-MetalLB-blue?style=flat-square)
![kube-vip](https://img.shields.io/badge/HA-kube--vip-blueviolet?style=flat-square)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=flat-square&logo=kubernetes&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%23EE0000.svg?style=flat-square&logo=ansible&logoColor=white)
![ArgoCD](https://img.shields.io/badge/Argo%20CD-%23ef7b4d.svg?style=flat-square&logo=argo&logoColor=white)
![Kubeadm HA](https://img.shields.io/badge/HA-Kubeadm-blueviolet?style=flat-square)
![Exam](https://img.shields.io/badge/Learning-CKA-blue?style=flat-square&logo=linuxfoundation)

This repo was initially built to teach me Docker and Compose skills as part of my self-hosting and homelab journey. But it has since evolved into a Kubernetes and Ansible learning project with a focus on production-like patterns and practices.

I chose a vanilla approach with `kubeadm` instead of something like `k3s` or `talos` because I am studying for the CKA and want to understand the underlying components and processes. I also want to practice building out the cluster with Ansible and then managing it through GitOps.

## Overview

The cluster gets bootstrapped through Ansible and then fully reconciled through ArgoCD. The GitOps repo is the single source of truth for cluster state after bootstrap. Since I'm studying for the CKA, the cluster is built with `kubeadm` to stay vanilla. I use `Longhorn` for replicated block storage on local disks, `MetalLB` for as an L2 load balancer, `Calico` for networking, and the control-plane is highly available with `kube-vip`.

## Inventory Model

Inventory is defined in [playbooks/inventory](/home/marthinus/Personal/homelab/playbooks/inventory).

Each host declares:

- `ansible_host`: SSH target
- `management_ip`: node IP used by kubeadm and kubelet
- `storage_disks`: Longhorn disk paths and tags

Cluster-wide variables declare:

- `api_virtual_ip`: shared API endpoint managed by kube-vip
- `api_virtual_ip_interface`: interface advertising the VIP
- `gitops_repo_url`, `gitops_revision`, `gitops_overlay_path`: ArgoCD source of truth
- `metallb_address_pool`, `longhorn_backup_target`, `longhorn_backup_endpoint`: platform defaults

## Bootstrap Flow

1. Update the inventory with the real control-plane nodes, worker nodes, management IPs, storage disk paths, and API VIP.
2. Run the supported bootstrap playbook.
3. Wait for ArgoCD to reconcile the platform, shared services, and application layers.

```bash
ansible-playbook -i playbooks/inventory ansible/deploy-k8s.yml
```

`ansible/deploy-k8s.yml` does only three things:

- prepares the nodes and bootstraps an HA kubeadm control plane
- joins workers through the stable API VIP
- installs Calico and ArgoCD, then seeds the root application

## GitOps Layout

The GitOps entrypoint is [k8s/overlays/dev](/home/marthinus/Personal/homelab/k8s/overlays/dev).

- [k8s/base/platform](/home/marthinus/Personal/homelab/k8s/base/platform): ingress, certs, load balancing, storage, operators, RBAC, and baseline platform defaults
- [k8s/base/shared-services](/home/marthinus/Personal/homelab/k8s/base/shared-services): PostgreSQL, RabbitMQ, Redis, Kafka, and Cassandra managed through maintained charts and operators
- [k8s/base/applications](/home/marthinus/Personal/homelab/k8s/base/applications): migrated user-facing workloads, currently `dev-pages`, `srv-ntfy`, `dev-cms`, `dev-pocket`, `ops-forge`, and `srv-n8n`

The overlay creates three ArgoCD projects and three layer applications so reconciliation order is explicit.

## Platform Defaults

- MetalLB L2 pool is `192.168.1.240-192.168.1.250`
- Longhorn default replica count `3` with recurring snapshot and backup jobs
- Traefik is default ingress class with HTTPS redirect and security headers
- Cert-manager cluster issuers for self-signed bootstrap and Let’s Encrypt
- Readonly RBAC for operators and default deny network policies for shared-service and application namespaces
- Pod Disruption Budgets for Traefik, Redis, RabbitMQ, and the stateless web workloads

## Runbooks

- [docs/runbooks/node-replacement.md](/home/marthinus/Personal/homelab/docs/runbooks/node-replacement.md)
- [docs/runbooks/recovery.md](/home/marthinus/Personal/homelab/docs/runbooks/recovery.md)
- [docs/runbooks/sealed-secrets.md](/home/marthinus/Personal/homelab/docs/runbooks/sealed-secrets.md)

## Architecture

The cluster has three layers. The platform layer includes the CNI, load balancer, ingress controller, cert manager, and storage operator. The shared services layer includes databases and messaging systems used by multiple applications. The application layer includes user-facing workloads like the CMS, PocketBase, Gitea forge, n8n workflow automation, ntfy notification system, and a placeholder dev-pages nginx deployment.

```mermaid
graph TB
    subgraph Users ["External/Home Network"]
        User(["User/Browser"])
    end

    subgraph Hardware ["Heterogeneous Nodes (3x HA Nodes)"]
        direction TB
        subgraph VIP ["Virtual IP (kube-vip)"]
            ControlPlaneAPI["Control Plane API"]
        end
        Node1["Node 01"]
        Node2["Node 02"]
        Node3["Node 03"]
    end

    subgraph K8s_Cluster ["Kubernetes Cluster (kubeadm)"]
        direction TB
        
        subgraph Ingress_Layer ["Ingress & LB Layer"]
            MLB["MetalLB (L2 LoadBalancer)"]
            TRA["Traefik (Ingress Controller)"]
            CM["cert-manager"]
        end

        subgraph Storage_Layer ["Storage Layer"]
            LH["Longhorn (Distributed Block Storage)"]
            LH_PVCs[("Replicated Volumes")]
        end

        subgraph Shared_Services ["Shared Services Layer"]
            PG[(PostgreSQL)]
            RMQ[[RabbitMQ]]
            RED[(Redis)]
            KFK[[Kafka]]
            CAS[(Cassandra)]
        end

        subgraph Apps ["Application Layer"]
            CMS["Strapi (dev-cms)"]
            PKT["PocketBase (dev-pocket)"]
            FORGE["Gitea (ops-forge)"]
            N8N["n8n (srv-n8n)"]
            NTFY["ntfy (srv-ntfy)"]
            DP["dev-pages (nginx)"]
        end
    end

    subgraph GitOps_Flow ["GitOps & Management"]
        GH["GitHub/Internal Forge"]
        ARG["ArgoCD"]
        ANS["Ansible Bootstrap"]
    end

    %% Connections
    User -->|HTTPS| MLB
    MLB --> TRA
    TRA --> CMS & PKT & FORGE & N8N & NTFY & DP
    
    CMS & PKT & FORGE & N8N --> Shared_Services
    Shared_Services & Apps --- LH
    LH --- LH_PVCs

    ANS -->|kubeadm init/join| Hardware
    GH -->|Sync| ARG
    ARG -->|Reconcile| K8s_Cluster
    
    classDef platform fill:#f9f,stroke:#333,stroke-width:2px;
    classDef storage fill:#ff9,stroke:#333,stroke-width:2px;
    classDef apps fill:#bbf,stroke:#333,stroke-width:2px;
    class MLB,TRA,CM platform;
    class LH,LH_PVCs storage;
    class CMS,PKT,FORGE,N8N,NTFY,DP apps;
```