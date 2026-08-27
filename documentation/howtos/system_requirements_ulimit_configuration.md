# System Requirements: ulimit Configuration

## Requirement

**All Kubernetes worker nodes must have file descriptor limits set to at least `65536`.**

This is critical for CEC v2 (Connections Engagement Center v2) and containerized workloads.

## Why This Matters

**Containerd v2 behavior change:** Pods now inherit file descriptor limits from the host system. If host limits are too low (default: 1024), pods will fail with:
- Silent library import failures
- "Too many open files" errors
- Connection timeouts
- Pod crashes under load

## Automated Configuration (Ansible)

The `containerd-install` role automatically configures:

**Systemd drop-in** (`/etc/systemd/system/containerd.service.d/limits.conf`): Sets `LimitNOFILE=65536`

## Verification

### Check Host
```bash
ulimit -n                                      # Expected: 65536
systemctl show containerd | grep LimitNOFILE   # Expected: LimitNOFILE=65536, LimitNOFILESoft=65536
```

### Check Pod
```bash
kubectl exec -n connections <pod-name> -c <container> -- sh -c "ulimit -n"   # Expected: 65536
```

### If Limits Are Wrong
```
LimitNOFILESoft=1024  ← Problem: systemd drop-in not applied
```
**Solution:** Run the containerd setup playbook or apply manual configuration below.

## Manual Configuration

```bash
# 1. Create systemd drop-in
sudo mkdir -p /etc/systemd/system/containerd.service.d
sudo tee /etc/systemd/system/containerd.service.d/limits.conf > /dev/null <<EOF
[Service]
LimitNOFILE=65536
EOF

# 2. Apply changes
sudo systemctl daemon-reload
sudo systemctl restart containerd

# 3. Restart pods to inherit new limits
kubectl rollout restart statefulset/dx-deployment-web-engine -n connections

# 4. Verify
systemctl show containerd | grep LimitNOFILE
kubectl exec -n connections <pod-name> -c <container> -- sh -c "ulimit -n"
```

**Note:** The systemd drop-in is sufficient. PAM limits (`/etc/security/limits.conf`) are not required for containerd v2.

## Troubleshooting

| Symptom | Cause | Solution |
|---------|-------|----------|
| CEC v2 libraries not imported | ulimit too low during import | Verify ulimit ≥ 65536, restart pods, re-import |
| "Too many open files" errors | ulimit < 65536 | Apply manual configuration, restart containerd & pods |
| Pods crash under load | Insufficient limits | Check ulimit and memory limits |

## Reference

**Other component limits:**
- OpenSearch: `fs.file-max=65536` (sysctl)
- DB2: 1024/65536 (soft/hard)
- Nginx, Connections: 64000/64000

