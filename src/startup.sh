#!/bin/bash

# Kasam Workspace Startup Banner and System Information
# Displays welcome message, available tools, and system status

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Clear screen
clear

# Display ASCII art banner
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                    🛡️  KASAM WORKSPACE READY  🛡️                          ║
║                                                                            ║
║             Browser-Based Linux Desktop for Cybersecurity Labs            ║
║                   Powered by KasmVNC + GitHub Codespaces                   ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓ WORKSPACE INITIALIZATION COMPLETE${NC}"
echo ""

# VNC Access Information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📺 KASMVNC DESKTOP ACCESS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Port:${NC} 6901 (KasmVNC Streaming)"
echo -e "  ${WHITE}Username:${NC} kasm_user"
echo -e "  ${WHITE}Password:${NC} codespaces"
echo -e "  ${WHITE}Resolution:${NC} 1920x1080 (configurable)"
echo -e "  ${WHITE}Browser URL:${NC} https://<codespace>.preview.app.github.dev:6901"
echo ""

# Auto-shutdown information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⏱️  AUTO-SHUTDOWN FEATURE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Idle Timeout:${NC} 15 minutes (900 seconds)"
echo -e "  ${WHITE}Warning Time:${NC} 60 seconds before shutdown"
echo -e "  ${WHITE}Activity Detection:${NC} X11 mouse/keyboard monitoring"
echo -e "  ${WHITE}Shutdown Command:${NC} Graceful system halt"
echo -e "  ${WHITE}Activity Log:${NC} /tmp/kasam-idle.log"
echo ""
echo -e "  ${MAGENTA}💡 Tip: Move your mouse or press a key to reset the idle timer${NC}"
echo ""

# Installed Tools
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🔧 INSTALLED CYBERSECURITY TOOLS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

tools=(
    "nmap:Network reconnaissance and port scanning"
    "wireshark-common:Packet analysis and network debugging"
    "john:Password cracking with dictionary attacks"
    "hashcat:GPU-accelerated hash cracking"
    "sqlmap:Automated SQL injection vulnerability testing"
    "gobuster:Web directory and subdomain brute-forcing"
    "hydra:Multi-protocol credential brute-force tool"
    "netcat-openbsd:Network utility for connections and transfers"
    "curl:HTTP client for API testing and data transfer"
    "git:Version control system"
    "htop:Interactive system process and resource monitor"
    "neofetch:System information display utility"
)

for tool_info in "${tools[@]}"; do
    tool_name="${tool_info%%:*}"
    tool_desc="${tool_info#*:}"
    
    if command -v "${tool_name}" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} ${WHITE}${tool_name}${NC} - ${tool_desc}"
    else
        echo -e "  ${RED}✗${NC} ${WHITE}${tool_name}${NC} - ${tool_desc} (NOT FOUND)"
    fi
done

echo ""

# System Information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}💻 SYSTEM INFORMATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# CPU Information
if [ -f /proc/cpuinfo ]; then
    cpu_count=$(grep -c processor /proc/cpuinfo)
    cpu_model=$(grep -m 1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)
    echo -e "  ${WHITE}CPU:${NC} $cpu_model (${cpu_count} cores)"
fi

# Memory Information
if command -v free >/dev/null 2>&1; then
    total_mem=$(free -h | awk 'NR==2 {print $2}')
    available_mem=$(free -h | awk 'NR==2 {print $7}')
    echo -e "  ${WHITE}Memory:${NC} ${available_mem} available of ${total_mem} total"
fi

# Disk Information
if command -v df >/dev/null 2>&1; then
    disk_usage=$(df -h / | awk 'NR==2 {print $4 " available of " $2}')
    echo -e "  ${WHITE}Disk:${NC} ${disk_usage}"
fi

# Uptime
if command -v uptime >/dev/null 2>&1; then
    uptime_info=$(uptime -p 2>/dev/null || uptime | awk -F'up' '{print $2}' | cut -d',' -f1)
    echo -e "  ${WHITE}Uptime:${NC} ${uptime_info}"
fi

# OS Information
if [ -f /etc/os-release ]; then
    os_version=$(grep '^VERSION=' /etc/os-release | cut -d'=' -f2 | xargs)
    os_name=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | xargs)
    echo -e "  ${WHITE}OS:${NC} ${os_name} ${os_version}"
fi

echo ""

# Quick Start Commands
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚡ QUICK START COMMANDS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}1. Check idle timer status:${NC}"
echo -e "     ps aux | grep inactivity-monitor"
echo ""
echo -e "  ${WHITE}2. View activity logs:${NC}"
echo -e "     tail -f /tmp/kasam-idle.log"
echo ""
echo -e "  ${WHITE}3. Display system info:${NC}"
echo -e "     neofetch"
echo ""
echo -e "  ${WHITE}4. Monitor system resources:${NC}"
echo -e "     htop"
echo ""
echo -e "  ${WHITE}5. Perform network scan:${NC}"
echo -e "     nmap -sn 192.168.1.0/24"
echo ""

# Idle Monitor Status
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📊 IDLE MONITOR STATUS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if pgrep -f "inactivity-monitor.sh" > /dev/null; then
    monitor_pid=$(pgrep -f "inactivity-monitor.sh" | head -1)
    echo -e "  ${GREEN}✓ Inactivity Monitor Running${NC}"
    echo -e "  ${WHITE}PID:${NC} $monitor_pid"
    
    if [ -f /tmp/kasam-idle.log ]; then
        last_check=$(tail -1 /tmp/kasam-idle.log)
        echo -e "  ${WHITE}Last Activity Check:${NC} $last_check"
    fi
else
    echo -e "  ${RED}✗ Inactivity Monitor NOT Running${NC}"
    echo -e "  ${YELLOW}Start manually: /usr/local/bin/inactivity-monitor.sh &${NC}"
fi

echo ""

# Ethical Hacking Disclaimer
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}⚠️  ETHICAL HACKING DISCLAIMER${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}This workspace is for AUTHORIZED security testing ONLY.${NC}"
echo ""
echo -e "  ${YELLOW}✓ Use only on systems you own or have explicit permission to test${NC}"
echo -e "  ${YELLOW}✓ All security tools must be used legally and responsibly${NC}"
echo -e "  ${YELLOW}✓ Unauthorized access to computer systems is a federal crime${NC}"
echo -e "  ${YELLOW}✓ Report vulnerabilities through proper disclosure channels${NC}"
echo ""
echo -e "  ${WHITE}Violating this disclaimer may result in criminal prosecution.${NC}"
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Ready to begin your authorized security testing! 🚀${NC}"
echo ""
