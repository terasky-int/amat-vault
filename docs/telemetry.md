### **Telemetry with Vault and Splunk**  

**Vault telemetry** provides valuable insights into system performance, security events, and audit logs, which can be collected and analyzed using monitoring tools like **Splunk**. This guide focuses on configuring **Vault’s telemetry and audit logging**, ensuring that logs and metrics are forwarded correctly. While **Splunk setup is a prerequisite**, this guide will only cover the necessary **Vault-side configuration** to enable telemetry and auditing.  

---

## **Prerequisites**  

1. Ensure Splunk is configured to receive Vault telemetry and audit logs. Follow this [official guide](https://developer.hashicorp.com/vault/tutorials/monitoring/monitor-telemetry-audit-splunk).  
2. Verify that your **Helm configuration** includes the required **telemetry stanza** in [`values.yaml`](../installation/openshift/values.yaml#L227-L231):  

```yaml
telemetry {
    dogstatsd_addr = "localhost:8125"
    enable_hostname_label = true
    prometheus_retention_time = "0h"
}
```

---

## **Steps on the Vault Side**  

Enable **audit logging** in Vault and configure it to send audit logs to a file for Splunk auditing:  

```bash
vault audit enable file file_path=/vault/audit/vault-audit.log mode=744
```

### **Command Explanation:**  
- **`vault audit enable file`** → Enables Vault’s audit logging to a file.  
- **`file_path=/vault/audit/vault-audit.log`** → Specifies the path where audit logs will be stored.  
- **`mode=744`** → Sets file permissions (**read/write for owner, read for others**), ensuring logs are accessible but secured.  

This configuration allows **Observability tools like Splunk** to ingest Vault audit logs from the specified file for further analysis and monitoring.