# Backup And Recovery

This runbook covers etcd, Longhorn, and operator-managed application data.

## etcd Snapshot

Run on any healthy control-plane node.

```bash
ETCDCTL_API=3 \
etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --endpoints=https://127.0.0.1:2379 \
  snapshot save /var/backups/etcd/$(date +%F-%H%M%S).db
```

Validate the snapshot immediately.

```bash
ETCDCTL_API=3 etcdctl snapshot status /var/backups/etcd/<snapshot>.db --write-out=table
```

## Restore etcd In A Test Environment

1. Stop kubelet on the test control-plane node.
2. Move the existing etcd data directory aside.
3. Restore the snapshot.

```bash
ETCDCTL_API=3 etcdctl snapshot restore /var/backups/etcd/<snapshot>.db --data-dir /var/lib/etcd-restore
```

4. Point the static etcd manifest to the restored data directory.
5. Start kubelet and wait for the API to recover.
6. Validate `kubectl get nodes` and `kubectl get pods -A`.

## Longhorn Backups

The platform config defines recurring Longhorn snapshot and backup jobs. Before relying on them in production:

1. Replace the placeholder secret in `longhorn-system/longhorn-backup-target` with a real sealed secret.
2. Confirm the backup target is reachable from all Longhorn nodes.
3. Verify recurring jobs from the Longhorn UI or CR status.

Restore flow:

1. Create a replacement PVC from the chosen Longhorn backup.
2. Attach it to a test workload.
3. Validate filesystem integrity and application startup before cutting over.

## PostgreSQL Recovery

CloudNativePG is configured for object-store backups and daily scheduled backups.

Restore procedure:

1. Provision a temporary namespace.
2. Create the same object-store credentials secret there.
3. Create a new CloudNativePG `Cluster` resource using the original backup destination and a `bootstrap.recovery` stanza.
4. Validate connectivity and application data before promoting or swapping traffic.

## Application Recovery Validation

The minimum recovery test for this repo is:

1. Restore one etcd snapshot in a test environment.
2. Restore one Longhorn-backed workload or database backup.
3. Confirm ingress, PVC attachment, and application health checks pass after restore.