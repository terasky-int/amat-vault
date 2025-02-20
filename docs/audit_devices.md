# **Audit Device Configuration**  

Configure Vault to **send audit logs to a SIEM** via a TCP socket:  

```sh
vault audit enable socket address=10.41.173.137:10540 socket_type=tcp
```

This ensures that all audit logs are **streamed in real-time** to the configured SIEM for monitoring and analysis.