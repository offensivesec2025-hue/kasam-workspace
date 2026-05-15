#!/bin/bash

# Kasam Workspace Startup Script
# Displays welcome banner, system info, and idle timer status

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Banner
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     ██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ███╗          ║
║     ██║ ██╔╝██╔══██╗██╔════╝██╔══██╗████╗ ████║          ║
║     █████╔╝ ███████║███████╗███████║██╔████╔██║          ║
║     ██╔═██╗ ██╔══██║╚════██║██╔══██║██║╚██╔╝██║          ║
║     ██║  ██╗██║  ██║███████║██║  ██║██║ ╚═╝ ██║          ║
║     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝          ║
║                                                            ║
║     Browser-Based Linux Desktop for Cybersecurity         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}[✓] Kasam Workspace Ready${NC}"
echo ""

# VNC Access Information
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}KasmVNC Desktop Access:${NC}"
echo -e "${CYAN}  Port:       6901${NC}"
echo -e "${CYAN}  Username:   kasm_user${NC}"
echo -e "${CYAN}  Password:   codespaces${NC}"
echo -e "${CYAN}  URL:        https://\$CODESPACE_NAME.preview.app.github.dev:6901${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Auto-shutdown Feature
echo -e "${MAGENTA}Auto-Shutdown Configuration:${NC}"
echo -e "${YELLOW}  Timeout:    15 minutes (900 seconds) of inactivity${NC}"
echo -e "${YELLOW}  Warning:    60 seconds before shutdown${NC}"
echo -e "${YELLOW}  Monitor:    Tracks mouse/keyboard activity${NC}"
echo -e "${YELLOW}  Logs:       /tmp/kasam-idle.log${NC}"
echo ""

# Check if inactivity monitor is running
if pgrep -f "inactivity-monitor.sh" > /dev/null; then
    echo -e "${GREEN}[✓] Inactivity Monitor: RUNNING${NC}"
    IDLE_LOG="/tmp/kasam-idle.log"
    if [ -f "$IDLE_LOG" ]; then
        LAST_STATUS=$(tail -1 "$IDLE_LOG" 2>/dev/null | grep -oP 'Idle \K[0-9]+' || echo "N/A")
        echo -e "${CYAN}    Last Status: ${LAST_STATUS}s idle${NC}"
        echo -e "${CYAN}    View logs: tail -f /tmp/kasam-idle.log${NC}"
    fi
else
    echo -e "${RED}[✗] Inactivity Monitor: NOT RUNNING${NC}"
    echo -e "${YELLOW}    Start manually: nohup /usr/local/bin/inactivity-monitor.sh &${NC}"
fi
echo ""

# Installed Tools Section
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Installed Cybersecurity Tools:${NC}"
echo ""

# Function to check tool availability and display status
check_tool() {
    local tool=$1
    local description=$2
    
    if command -v "$tool" &> /dev/null; then
        VERSION=$(eval "$tool --version 2>&1 | head -1" 2>/dev/null || echo "")
        printf "  ${GREEN}[✓]${NC} %-15s - ${CYAN}%s${NC}\n" "$tool" "$description"
    else
        printf "  ${RED}[✗]${NC} %-15s - ${CYAN}%s${NC}\n" "$tool" "$description"
    fi
}

# Network Tools
echo -e "${YELLOW}Network & Reconnaissance:${NC}"
check_tool "nmap" "Port scanning, service enumeration"
check_tool "netcat" "Banner grabbing, port listening"
check_tool "curl" "HTTP requests, API testing"

# Web Testing
echo ""
echo -e "${YELLOW}Web Application Testing:${NC}"
check_tool "sqlmap" "SQL injection vulnerability scanning"
check_tool "gobuster" "Path & subdomain enumeration"
check_tool "wireshark" "Packet capture & analysis"

# Credential Attacks
echo ""
echo -e "${YELLOW}Password Cracking & Brute-force:${NC}"
check_tool "hydra" "Online credential brute-force"
check_tool "john" "Password cracking (CPU)"
check_tool "hashcat" "Hash cracking (GPU-accelerated)"

# System Utilities
echo ""
echo -e "${YELLOW}System & Utilities:${NC}"
check_tool "git" "Version control"
check_tool "htop" "Process monitoring"
check_tool "neofetch" "System information"

echo ""

# System Information
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}System Information:${NC}"
echo ""

# CPU Info
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
CPU_CORES=$(nproc)
echo -e "  ${CYAN}CPU:${NC}        $CPU_MODEL ($CPU_CORES cores)"

# Memory Info
TOTAL_MEM=$(free -h | grep Mem | awk '{print $2}')
AVAIL_MEM=$(free -h | grep Mem | awk '{print $7}')
echo -e "  ${CYAN}Memory:${NC}     $TOTAL_MEM total (${AVAIL_MEM} available)"

# Disk Info
DISK_TOTAL=$(df -h / | tail -1 | awk '{print $2}')
DISK_USED=$(df -h / | tail -1 | awk '{print $3}')
DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')
echo -e "  ${CYAN}Disk:${NC}       $DISK_TOTAL ($DISK_USED used, $DISK_AVAIL available)"

# Uptime
UPTIME=$(uptime -p | sed 's/up //')
echo -e "  ${CYAN}Uptime:${NC}     $UPTIME"

# OS Info
OS_INFO=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
echo -e "  ${CYAN}OS:${NC}        $OS_INFO"

echo ""

# Quick Start Guide
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Quick Start Commands:${NC}"
echo ""
echo -e "  ${YELLOW}1. Open Desktop:${NC}"
echo -e "     Access port 6901 in your browser (see VNC info above)"
echo ""
echo -e "  ${YELLOW}2. Network Scan:${NC}"
echo -e "     ${CYAN}nmap -p- -sV 192.168.0.0/24${NC}"
echo ""
echo -e "  ${YELLOW}3. SQL Injection Test:${NC}"
echo -e "     ${CYAN}sqlmap -u 'http://target.com/page?id=1' --dbs${NC}"
echo ""
echo -e "  ${YELLOW}4. Brute-force Credentials:${NC}"
echo -e "     ${CYAN}hydra -l admin -P passwords.txt ssh://target.com${NC}"
echo ""
echo -e "  ${YELLOW}5. Monitor Idle Time:${NC}"
echo -e "     ${CYAN}tail -f /tmp/kasam-idle.log${NC}"
echo ""

# Idle Timer Status
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}Idle Timer Status:${NC}"
echo ""
if [ -f "/tmp/kasam-idle.log" ]; then
    MONITOR_PID=$(pgrep -f "inactivity-monitor.sh" || echo "N/A")
    echo -e "  ${CYAN}Monitor PID:${NC}       $MONITOR_PID"
    echo -e "  ${CYAN}Log Location:${NC}     /tmp/kasam-idle.log"
    echo -e "  ${CYAN}Current Time:${NC}     $(date '+%Y-%m-%d %H:%M:%S')"
    
    if [ -f "/tmp/kasam-idle.log" ]; then
        LAST_LOG=$(tail -1 /tmp/kasam-idle.log 2>/dev/null)
        echo -e "  ${CYAN}Last Log Entry:${NC}   $LAST_LOG"
    fi
else
    echo -e "  ${YELLOW}Monitor log not yet created. Monitor starting...${NC}"
fi

echo ""

# Ethical Disclaimer
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo -e "${RED}ETHICAL HACKING DISCLAIMER${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠️  AUTHORIZED USE ONLY${NC}"
echo ""
echo -e "The tools in this workspace are powerful and can cause harm if misused."
echo ""
echo -e "${GREEN}DO:${NC}"
echo -e "  ✓ Test systems you own"
echo -e "  ✓ Test with explicit written authorization"
echo -e "  ✓ Use for authorized security assessments"
echo -e "  ✓ Report vulnerabilities responsibly"
echo ""
echo -e "${RED}DON'T:${NC}"
echo -e "  ✗ Test systems without permission"
echo -e "  ✗ Exceed authorization scope"
echo -e "  ✗ Leave backdoors or damage systems"
echo -e "  ✗ Disclose vulnerabilities publicly without notice"
echo ""
echo -e "Unauthorized access is ${RED}ILLEGAL${NC} and punishable by law."
echo ""
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Footer
echo -e "${CYAN}For detailed setup instructions, see README.md${NC}"
echo -e "${CYAN}For development guidelines, see .github/copilot-instructions.md${NC}"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Kasam is ready for secure, authorized testing.           ║${NC}"
echo -e "${GREEN}║  Safe hacking practices make the internet safer for all.  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
