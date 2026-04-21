# Sealed Secrets

This repo models sensitive Kubernetes credentials as `SealedSecret` resources instead of plain `Secret` manifests.

The committed `encryptedData` values are placeholders and must be replaced with real ciphertext generated from the active cluster's Sealed Secrets public certificate before deployment.

## Prerequisites

- `kubeseal` installed locally
- access to the target cluster context
- the `sealed-secrets` controller reconciled in the `sealed-secrets` namespace

## Fetch the public certificate

```bash
kubeseal --controller-name sealed-secrets \
  --controller-namespace sealed-secrets \
  --fetch-cert > /tmp/homelab-sealed-secrets.pem
```

## Seal a value

Use the same secret name, namespace, and key already declared in the manifest:

```bash
printf '%s' 'replace-me' \
  | kubeseal \
      --raw \
      --from-file=/dev/stdin \
      --name n8n-config \
      --namespace apps-utility \
      --scope strict \
      --cert /tmp/homelab-sealed-secrets.pem
```

Replace the matching `encryptedData` entry in the manifest with the returned ciphertext.

## Files that still need real ciphertext

- `k8s/base/platform-config/defaults.yaml`
- `k8s/base/shared-services/db-postgres.yaml`
- `k8s/base/shared-services/kv-redis.yaml`
- `k8s/base/shared-services/mq-kafka.yaml`
- `k8s/base/shared-services/db-cassandra.yaml`
- `k8s/base/applications/dev-cms.yaml`
- `k8s/base/applications/ops-forge.yaml`
- `k8s/base/applications/srv-n8n.yaml`
- `k8s/base/applications/app-db-bootstrap.yaml`

## Validation

After replacing all placeholder ciphertext values, render the overlay and confirm there are no remaining placeholder markers:

```bash
kubectl kustomize k8s/overlays/dev > /tmp/rendered-dev.yaml
rg 'AgReplaceWithKubesealCiphertext' k8s/base
```

The ripgrep command should return no matches before a real deployment.