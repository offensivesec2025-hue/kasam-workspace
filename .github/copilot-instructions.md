# Kasam Workspace - Copilot Development Guidelines

## Project Overview

**Kasam** is a browser-based Linux desktop workspace environment for GitHub Codespaces, featuring:
- KasmVNC remote desktop streaming (port 6901)
- Integrated cybersecurity and penetration testing tools
- Automatic resource management via inactivity-based shutdown
- Educational platform for authorized security testing

## Architecture

### Container Stack
```
GitHub Codespaces
  └── Docker Container (kasmweb/core-ubuntu-jammy:1.16.0)
      ├── X11 Desktop Environment
      ├── KasmVNC Streaming (Port 6901)
      ├── Cybersecurity Tools Suite
      └── Inactivity Monitor (Auto-shutdown)
```

### KasmVNC Streaming Architecture

**How it works:**
1. Desktop environment (X11) runs inside container
2. VNC server (KasmVNC) streams desktop to browser
3. GitHub Codespaces forwards port 6901
4. User connects via browser on `https://<codespace>.preview.app.github.dev:6901`
5. KasmVNC transcodes display to H.264/VP8 video stream
6. All input (mouse/keyboard) captured and sent back to container

**Why KasmVNC:**
- Browser-native H.264 streaming (no external VNC client needed)
- GPU-accelerated encoding (if available)
- Low latency (~100-200ms)
- Adaptive quality based on network
- Secure WebSocket connections

### Inactivity Monitoring System

**Purpose:** Save GitHub Codespaces compute hours by auto-shutting down inactive instances

**Detection Mechanism:**
- Primary: X11 idle time detection via `xprintidle` (millisecond precision)
- Fallback: `/dev/input/event*` file modification time tracking
- Check interval: Every 30 seconds
- Minimal CPU overhead (~1-2%)

**Timeline:**
```
0s ────────────── 675s (75%) ────────────── 840s (93%) ────── 900s (TIMEOUT)
Active          Warning Zone              Final Warning       Shutdown
                (approaching)             (60s before)
                                         Zenity Dialog
                                         Appears
```

**Shutdown Process:**
1. Detect 900s (15 min) of inactivity
2. Display zenity warning dialog: "Kasam shutting down in 60s due to inactivity"
3. Wait 60 seconds for user activity to reset timer
4. Execute `shutdown -h now` if still idle
5. Log all events to `/tmp/kasam-idle.log`

## Coding Standards

### Bash Scripts
- Use `#!/bin/bash` shebang (not `/bin/sh`)
- Quote all variables: `"$variable"`
- Use `[[` for conditionals: `if [[ $x -gt 0 ]]; then`
- Log with ISO 8601 timestamps: `$(date '+%Y-%m-%d %H:%M:%S')`
- Comment complex sections
- Use meaningful variable names (not `$1`, `$2`)
- Check command existence: `command -v <cmd> >/dev/null 2>&1`
- Always add error handling and logging

**Example:**
```bash
#!/bin/bash

IDLE_TIMEOUT=${IDLE_TIMEOUT:-900}
LOG_FILE="/tmp/kasam-idle.log"

log_message() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_FILE"
}

if command -v xprintidle >/dev/null 2>&1; then
    idle_time=$(xprintidle 2>/dev/null | awk '{print int($1/1000)}')
else
    log_message "Warning: xprintidle not available"
fi
```

### JSON Configuration
- Use 2-space indentation
- Keep `devcontainer.json` validation-compatible
- Document all non-obvious fields
- Use environment variable expansion for secrets

**Example:**
```json
{
  "name": "Kasam Workspace",
  "image": "kasmweb/core-ubuntu-jammy:1.16.0",
  "containerEnv": {
    "VNC_PW": "codespaces",
    "IDLE_TIMEOUT": "900"
  }
}
```

### Dockerfile
- Use specific base image versions (not `latest`)
- Multi-stage builds for size optimization
- Combine `RUN` commands to reduce layers
- Clean up package manager cache: `&& apt-get clean && rm -rf /var/lib/apt/lists/*`
- Use `LABEL` for metadata
- Document exposed ports and volumes

**Example:**
```dockerfile
FROM kasmweb/core-ubuntu-jammy:1.16.0

ENV VNC_PW=codespaces PUID=1000 PGID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    nmap \
    wireshark-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chmod +x /usr/local/bin/inactivity-monitor.sh

EXPOSE 6901
```

## Ethical Hacking Framework

### Authorization Requirements
✅ **ONLY** perform security testing on:
- Systems you own
- Systems with explicit written authorization
- Isolated lab environments
- Authorized penetration testing engagements

### Legal Framework
- **Unauthorized Computer Access:** Federal crime (US: CFAA)
- **Data Theft:** Criminal and civil liability
- **Denial of Service:** Federal crime
- **Privilege Escalation:** May violate computer fraud laws

### Responsible Disclosure
1. **Find vulnerability** → **Document privately**
2. **Contact vendor** → **Allow 90-day remediation window**
3. **Public disclosure** → **Only after patch available**
4. **No exploit public release** → **Without permission**

### Tool Usage Guidelines

| Tool | Authorized Use | Unauthorized Use |
|------|----------------|------------------|
| **nmap** | Port scanning own network | Scanning others' networks |
| **sqlmap** | Testing own apps | Attacking production systems |
| **hydra** | Password policy testing | Credential stuffing attacks |
| **hashcat** | Hash cracking for own hashes | Rainbow table attacks on others |
| **wireshark** | Network protocol analysis | Intercepting others' traffic |

## Development Tasks

### Adding New Tools

**Task:** Install additional cybersecurity tool

```bash
# 1. Update Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    new-tool-name \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Update README.md tools table
| **new-tool** | Purpose | Use case |

# 3. Test in Codespace
# 4. Commit: git commit -m "Add new-tool for XYZ testing"
```

### Modifying Inactivity Timeout

**Task:** Change auto-shutdown timeout from 15 to 30 minutes

```bash
# 1. Edit .env.example
IDLE_TIMEOUT=1800  # 30 minutes instead of 900

# 2. Update README.md
Replace all references from "15 minutes" to "30 minutes"

# 3. Rebuild container
F1 > Rebuild Container

# 4. Test: Wait 30+ minutes and verify shutdown occurs
```

### Debugging Inactivity Monitor

**Task:** Troubleshoot why shutdown triggers too early

```bash
# 1. Check monitor logs
tail -f /tmp/kasam-idle.log

# 2. Verify X11 is running
echo $DISPLAY
ps aux | grep X

# 3. Check inactivity monitor process
ps aux | grep inactivity-monitor

# 4. Test xprintidle (if available)
xprintidle  # Should return milliseconds since last input

# 5. Monitor in real-time
while true; do echo "Idle: $(xprintidle)ms"; sleep 5; done
```

### Performance Optimization

**Task:** Reduce memory footprint

```bash
# 1. Profile current usage
free -h
top -b -n 1 | head -20

# 2. Disable unnecessary services
sudo systemctl disable snapd
sudo systemctl stop snapd

# 3. Reduce shared memory if needed
# Edit devcontainer.json: "--shm-size=256m" (was 512m)

# 4. Monitor improvements
free -h  # After rebuild
```

## Security Considerations

### VNC Password Management
- **Never commit passwords** to repository
- Use `.env.example` as template only
- Default `codespaces` is acceptable for Codespaces environment
- Codespaces provides authentication layer via GitHub

### Container Isolation
- Each Codespace instance is isolated
- Port forwarding requires GitHub authentication
- No network access between Codespaces
- Data deleted when Codespace deleted

### Inactivity Monitor Security
- Runs as `kasm_user` (not root)
- No privilege escalation needed
- Logs contain only timestamps and idle duration
- No sensitive data captured

## Troubleshooting Guide

### KasmVNC Connection Issues

```bash
# Check if VNC server is running
sudo systemctl status kasm-srv

# Check port listening
sudo netstat -tlnp | grep 6901

# Restart KasmVNC service
sudo systemctl restart kasm-srv

# View VNC logs
sudo tail -100 /var/log/kasm/
```

### Desktop Not Displaying

```bash
# Check X11 is running
ps aux | grep X
echo $DISPLAY

# Check NVIDIA (if GPU available)
nvidia-smi

# Restart X11
sudo systemctl restart kasm-srv
```

### Shutdown Triggers Unexpectedly

```bash
# Check inactivity monitor logs
tail -100 /tmp/kasam-idle.log

# Verify timeout setting
echo $IDLE_TIMEOUT

# Reset timer by moving mouse/pressing key
# Then check log:
tail /tmp/kasam-idle.log

# Increase timeout if needed
export IDLE_TIMEOUT=1800  # 30 minutes
```

## Resources

- [KasmVNC Official Docs](https://www.kasmweb.com/kasmvnc)
- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [devcontainers.json Specification](https://containers.dev/implementors/json_reference/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [HackerOne Responsible Disclosure](https://www.hackerone.com/)

---

**Remember:** This workspace is for **authorized security testing and educational purposes only**. All tools should be used responsibly and legally.
