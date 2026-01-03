# Kubernetes Attack Scripts

This directory contains scripts that simulate various Kubernetes attack scenarios and anomalous activities. These scripts are designed to be detected by security tools like RHACS (Red Hat Advanced Cluster Security), Falco, and other Kubernetes security monitoring solutions.

## Attack Scripts

### Application-Level Attacks

1. **backend-attack.sh** - Struts RCE exploit with cryptocurrency mining payload
   - Exploits Apache Struts vulnerability (CVE-2017-5638)
   - Executes cryptocurrency miner in backend namespace
   - Usage: `./backend-attack.sh`

2. **frontend-attack.sh** - Struts RCE exploit with network scanning payload
   - Exploits Apache Struts vulnerability
   - Executes network scanning commands (nmap)
   - Usage: `./frontend-attack.sh`

3. **crypto-attack.sh** - Cryptocurrency mining attack
   - Similar to backend-attack.sh
   - Installs and runs cryptocurrency miner
   - Usage: `./crypto-attack.sh`

4. **struts-2024-53677-attack-S2-067.py** - Struts file upload exploit (CVE-2024-53677) - Python version
   - Python script for file upload vulnerability
   - Allows arbitrary file upload and execution
   - Usage: `python struts-2024-53677-attack-S2-067.py -u <url> --upload_endpoint <endpoint> --files <files> --destination <path>`

5. **struts-cve-2024-53677-attack.sh** - Struts file upload exploit (CVE-2024-53677) - Shell version
   - Shell script version that attacks the struts-cve-2024-53677 application
   - Creates and uploads a JSP webshell
   - Executes commands via the uploaded webshell
   - Usage: `./struts-cve-2024-53677-attack.sh [upload_endpoint] [destination_path] [command]`
   - Example: `./struts-cve-2024-53677-attack.sh /upload.action ../../../../../usr/local/tomcat/webapps/ROOT/shell.jsp "id"`

### Kubernetes-Specific Attacks

6. **privilege-escalation-attack.sh** - Container privilege escalation attempts
   - Attempts to gain root access
   - Tries to modify security contexts
   - Accesses sensitive files (/etc/shadow)
   - Usage: `./privilege-escalation-attack.sh [namespace] [pod-name]`

7. **service-account-token-theft.sh** - Service account token theft and lateral movement
   - Extracts service account tokens from pods
   - Uses stolen tokens for unauthorized API access
   - Attempts lateral movement between namespaces
   - Usage: `./service-account-token-theft.sh [source-namespace] [target-namespace]`

8. **secret-enumeration-attack.sh** - Kubernetes secret enumeration
   - Lists and accesses secrets in a namespace
   - Attempts to read service account tokens, TLS certificates, and image pull secrets
   - Tries to access secrets from within pods
   - Usage: `./secret-enumeration-attack.sh [namespace]`

9. **network-scanning-attack.sh** - Internal network scanning and reconnaissance
   - Scans Kubernetes service IPs
   - Performs DNS enumeration
   - Attempts to access Kubernetes API server and etcd
   - Port scans common Kubernetes ports
   - Usage: `./network-scanning-attack.sh [source-namespace] [target-namespace]`

10. **rbac-privilege-escalation.sh** - RBAC privilege escalation attempts
   - Attempts to create cluster-admin role bindings
   - Tries to modify existing role bindings
   - Attempts to access cluster-scoped resources
   - Usage: `./rbac-privilege-escalation.sh [namespace]`

11. **resource-exhaustion-attack.sh** - Resource exhaustion (DoS) attack
    - Creates many resource-intensive pods
    - Attempts to exhaust CPU, memory, and storage
    - Simulates denial of service attack
    - Usage: `./resource-exhaustion-attack.sh [namespace] [number-of-pods]`

12. **configmap-enumeration-attack.sh** - ConfigMap enumeration and access
    - Lists all ConfigMaps in a namespace
    - Attempts to read ConfigMap contents
    - Tries to access mounted ConfigMaps from pods
    - Attempts to create/modify ConfigMaps
    - Usage: `./configmap-enumeration-attack.sh [namespace]`

13. **container-escape-attack.sh** - Container escape attempts
    - Checks for privileged containers
    - Attempts to access host filesystem
    - Tries to access Docker/CRI sockets
    - Attempts to mount host paths
    - Tries to access kubelet API
    - Usage: `./container-escape-attack.sh [namespace]`

## Detection Capabilities

These attacks are designed to trigger alerts in:

- **RHACS (Red Hat Advanced Cluster Security)**
  - Process execution policies
  - Network policy violations
  - RBAC violations
  - Secret access violations
  - Privilege escalation attempts

- **Falco**
  - System call monitoring
  - File access violations
  - Network activity
  - Privilege escalation

- **Kubernetes Audit Logging**
  - API server access patterns
  - RBAC violations
  - Resource creation/modification

- **Network Policies**
  - Unauthorized network connections
  - Cross-namespace communication

## Usage Examples

```bash
# Run privilege escalation attack
./privilege-escalation-attack.sh frontend

# Run service account token theft
./service-account-token-theft.sh frontend backend

# Run network scanning
./network-scanning-attack.sh frontend backend

# Run resource exhaustion attack (creates 50 pods)
./resource-exhaustion-attack.sh frontend 50

# Run Struts file upload exploit
./struts-cve-2024-53677-attack.sh /upload.action ../../../../../usr/local/tomcat/webapps/ROOT/shell.jsp "whoami"
```

## Security Note

⚠️ **WARNING**: These scripts are designed for security testing and demonstration purposes only. Only run these scripts in isolated test environments with proper authorization. Unauthorized use of these scripts against systems you don't own or have explicit permission to test is illegal.

## Cleanup

After running attacks, clean up created resources:

```bash
# Delete test pods
kubectl delete pods -n <namespace> -l run=<attack-pattern>

# Delete test namespaces
kubectl delete namespace rbac-test-*

# Delete test ConfigMaps
kubectl delete configmap -n <namespace> test-config-*
```

