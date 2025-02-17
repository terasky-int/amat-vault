# Auto Snapshot

Based on this [article](https://developer.hashicorp.com/vault/api-docs/v1.16.x/system/storage/raftautosnapshots)

**Note**: Make sure you are on the right version.

Commands For auto snapshot:
 
1. Create auto snapshot confiuration 
```bash
vault write sys/storage/raft/snapshot-auto/config/auto-snapshots \
    storage_type=azure-blob \
    file_prefix=vault-snapshot \
    interval=24h \
    retain=30 \
    azure_account_name=<your_storage_account_name> \
    azure_account_key=<your_storage_account_key> \
    azure_container_name=<your_container_name> \
    path_prefix=vault/backups/
```
 
2. to inspect configuration
 
```bash
vault read sys/storage/raft/snapshot-auto/config/auto-snapshots
```

3. To see the status

```bash
vault read sys/storage/raft/snapshot-auto/status/auto-snapshots
```