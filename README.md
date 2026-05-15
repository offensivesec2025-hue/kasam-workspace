# Kasam Browser Desktop - Complete Linux Workspace for Codespaces

## Overview

**Kasam** is a complete browser-based Linux desktop environment optimized for GitHub Codespaces, featuring KasmVNC streaming, integrated cybersecurity tools, and automatic resource management via inactivity-based shutdown.

## Quick Start

### 1. Launch Codespace
Create a new Codespace from this repository. The container will build with all cybersecurity tools pre-installed.

### 2. Access Desktop via KasmVNC
- **URL:** `https://<your-codespace-name>.preview.app.github.dev:6901`
- **Port:** `6901` (automatically forwarded)
- **Username:** `kasm_user`
- **Password:** `codespaces`
- **Resolution:** `1920x1080` (configurable in `.env.example`)

### 3. Monitor Auto-Shutdown
The system automatically logs activity and initiates shutdown after **15 minutes (900 seconds)** of inactivity:
- **Idle Timer:** Tracks mouse/keyboard activity via X11 and `/dev/input/*`
- **Warning Dialog:** Appears 60 seconds before shutdown with `zenity`
- **Graceful Shutdown:** `shutdown -h now` after 900s idle
- **Logs:** Monitored to `/tmp/kasam-idle.log`

## Installed Cybersecurity Tools

| Tool | Purpose | Use Case |
|------|---------|----------|
| **nmap** | Network reconnaissance | Port scanning, service discovery |
| **wireshark-common** | Packet analysis | Network traffic inspection, protocol analysis |
| **john** | Password cracking | Hash cracking, dictionary attacks |
| **hashcat** | GPU password cracking | Advanced hash cracking with GPU acceleration |
| **sqlmap** | SQL injection testing | Automated SQL injection vulnerability scanning |
| **gobuster** | Web directory brute-force | Path enumeration, subdomain discovery |
| **hydra** | Credential brute-force | Login testing, password spraying |
| **netcat-openbsd** | Network utility | Port listening, banner grabbing, data transfer |
| **curl** | HTTP client | API testing, data exfiltration |
| **git** | Version control | Repository management |
| **htop** | System monitor | Process monitoring and management |
| **neofetch** | System info display | System specifications display |

## System Architecture

### Container Configuration
- **Base Image:** `kasmweb/core-ubuntu-jammy:1.16.0` (Ubuntu 22.04 LTS)
- **Shared Memory:** 512MB (optimized for X11 streaming)
- **Remote User:** `kasm_user` (UID 1000, GID 1000)
- **VNC Password:** `codespaces`

### Inactivity Monitor Features
- **Activity Detection:** Monitors X11 events and `/dev/input/event*` files
- **Check Interval:** Every 30 seconds
- **Timeout Duration:** 900 seconds (15 minutes)
- **Warning Period:** 60 seconds before shutdown
- **Logging:** Comprehensive activity logs to `/tmp/kasam-idle.log`

### Resource Management
- Automatically suspends resources after idle period
- Saves GitHub Codespaces compute hours
- Prevents accidental resource waste
- Can be extended by moving mouse or pressing keys

## Environment Variables

All configuration via `.env.example`:

```env
VNC_PW=codespaces              # KasmVNC password
PUID=1000                       # Process User ID
PGID=1000                       # Process Group ID
RESOLUTION=1920x1080          # Desktop resolution
IDLE_TIMEOUT=900               # Idle timeout in seconds (15 min)
WARNING_TIME=60                # Warning display time before shutdown
```

## Usage Examples

### Access Desktop
1. Click "Ports" tab in Codespace
2. Click the globe icon for port 6901
3. Login with `kasm_user:codespaces`

### Network Scanning with nmap
```bash
nmap -p- -sV 192.168.1.0/24
```

### SQL Injection Testing
```bash
sqlmap -u "http://target.com/page?id=1" --dbs
```

### Brute-force Credentials
```bash
hydra -l admin -P passwords.txt http://target.com/ http-post-form
```

### Monitor System Activity
```bash
tail -f /tmp/kasam-idle.log
```

### Check Current Idle Status
```bash
ps aux | grep inactivity-monitor
```

## Performance Optimization

- **Shared Memory:** 512MB allocation for smooth X11 rendering
- **VNC Compression:** Adaptive quality based on network conditions
- **CPU:** Single-threaded monitoring keeps resource usage minimal
- **Memory:** ~50-100MB for inactivity monitor process

## Troubleshooting

### KasmVNC Not Connecting
1. Verify port 6901 is forwarded in Codespace ports tab
2. Check VNC password: `codespaces`
3. Wait 30-60 seconds for `/dockerstartup/kasm_startup.sh` to complete
4. View container logs: `docker logs <container_id>`

### Shutdown Triggered Too Soon
1. Edit `.env.example` and increase `IDLE_TIMEOUT`
2. Move mouse or press keys to reset idle timer
3. Check logs: `tail -f /tmp/kasam-idle.log`

### Desktop Resolution Issues
1. Adjust `RESOLUTION` in `.env.example`
2. Rebuild container: `F1 > Rebuild Container`
3. Restart KasmVNC session

### Tools Not Installed
1. Verify Dockerfile build completed successfully
2. Check container logs for installation errors
3. Manually install: `sudo apt-get install <tool-name>`

## Security & Legal Disclaimer

⚠️ **ETHICAL USE ONLY**

This workspace is designed for authorized security testing and educational purposes only:

- **Authorized Testing:** Only test systems you own or have explicit written permission to test
- **Legal Compliance:** Unauthorized access to computer systems is illegal
- **Responsible Disclosure:** Report vulnerabilities through proper channels
- **Educational Use:** Use for learning penetration testing techniques in controlled environments
- **No Malicious Use:** Tools included are for defensive and authorized offensive security work

**Users are solely responsible for ensuring their use complies with all applicable laws and regulations.**

## Featured Tools Disclaimer

The included security tools are powerful and can cause harm if misused:
- **nmap** - Unauthorized port scanning may be illegal
- **sqlmap** - SQL injection testing requires authorization
- **hydra** - Credential cracking requires authorization
- **hashcat** - Password cracking is resource-intensive
- **wireshark** - Network capture requires proper permissions

## Screenshot

[Desktop Preview - KasmVNC Browser Interface]
```
┌─────────────────────────────────────────┐
│  Kasam Linux Desktop via KasmVNC        │
│  ✓ Full X11 environment                 │
│  ✓ Terminal, file manager, text editor  │
│  ✓ All cybersecurity tools installed    │
│  ✓ Auto-shutdown after 15min idle       │
└─────────────────────────────────────────┘
```

## References

- [KasmVNC Documentation](https://www.kasmweb.com/kasmvnc)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [nmap Official Guide](https://nmap.org/book/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

## Support

For issues or questions:
1. Check `/tmp/kasam-idle.log` for activity monitoring logs
2. Review `.devcontainer/devcontainer.json` configuration
3. Consult Dockerfile for tool installation details
4. Review `.github/copilot-instructions.md` for development guidelines

---

**Last Updated:** 2026-05-15  
**Version:** 1.0  
**License:** Educational Use Only
