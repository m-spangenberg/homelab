# Node Replacement

This runbook covers worker and control-plane replacement.

## Preconditions

- The replacement node has the same management network reachability as the failed node.
- The inventory in [playbooks/inventory](/home/marthinus/Personal/homelab/playbooks/inventory) is updated with the new `ansible_host`, `management_ip`, and `storage_disks` values.
- Longhorn backups and database backups are healthy before disruptive work starts.

## Replace A Worker Node

1. Drain the node if it is still reachable.

```bash
kubectl drain <worker> --ignore-daemonsets --delete-emptydir-data
```

2. Remove the node object once workloads are evacuated.

```bash
kubectl delete node <worker>
```

3. If Longhorn still shows orphaned replicas, wait for replica rebuilds to complete before deleting the old disk entry.

4. Rebuild or reprovision the replacement host.

5. Run bootstrap against only the replacement worker.

```bash
ansible-playbook -i playbooks/inventory ansible/deploy-k8s.yml --limit <worker>
```

6. Validate:

- `kubectl get nodes -o wide`
- `kubectl get pods -A -o wide`
- `kubectl -n longhorn-system get volumes.longhorn.io`
- `kubectl -n apps-web get ingress,svc,pods`

## Replace A Control-Plane Node

1. Confirm the API VIP remains healthy through the surviving control-plane nodes.

```bash
kubectl get --raw='/readyz?verbose'
```

2. If the failed node is still partially reachable, drain it.

```bash
kubectl drain <control-plane-node> --ignore-daemonsets --delete-emptydir-data
```

3. Remove the member from etcd and Kubernetes if the node is permanently gone.

```bash
kubectl delete node <control-plane-node>
```

4. Rebuild the host and keep the same inventory role in `kube_control_plane`.

5. Run bootstrap limited to the replacement control-plane node.

```bash
ansible-playbook -i playbooks/inventory ansible/deploy-k8s.yml --limit <control-plane-node>
```

6. Validate quorum and VIP continuity:

- `kubectl get nodes`
- `kubectl -n kube-system get pods -l component=kube-apiserver -o wide`
- `kubectl -n kube-system get pods -l component=etcd -o wide`
- `kubectl get endpoints kubernetes`

## Post-Replacement Checks

1. Longhorn replicas are healthy and balanced.
2. PostgreSQL primary and replicas are healthy.
3. RabbitMQ has quorum.
4. Redis master and replicas are healthy.
5. At least one ingress-backed application remains available during a worker drain.