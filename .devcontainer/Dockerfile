FROM kasmweb/core-ubuntu-jammy:1.16.0

# Set environment variables
ENV VNC_PW=codespaces \
    PUID=1000 \
    PGID=1000 \
    DEBIAN_FRONTEND=noninteractive

# Install cybersecurity and penetration testing tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    nmap \
    wireshark-common \
    john \
    hashcat \
    sqlmap \
    gobuster \
    hydra \
    netcat-openbsd \
    curl \
    git \
    htop \
    neofetch \
    zenity \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create inactivity monitor script
RUN cat > /usr/local/bin/inactivity-monitor.sh << 'EOF'
#!/bin/bash

# Kasam Inactivity Monitor Script
# Monitors X11 and /dev/input/* for activity
# Triggers auto-shutdown after 900 seconds (15 minutes) of inactivity

IDLE_TIMEOUT=${IDLE_TIMEOUT:-900}  # 15 minutes in seconds
WARNING_TIME=${WARNING_TIME:-60}    # 60 seconds warning before shutdown
CHECK_INTERVAL=30                   # Check every 30 seconds
LOG_FILE="/tmp/kasam-idle.log"

# Initialize log file
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Kasam Inactivity Monitor Started" > "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Idle Timeout: ${IDLE_TIMEOUT}s | Warning Time: ${WARNING_TIME}s" >> "$LOG_FILE"

# Function to get last activity time from X11
get_x11_activity() {
    if command -v xprintidle >/dev/null 2>&1; then
        xprintidle 2>/dev/null | awk '{print int($1/1000)}'
    else
        # Fallback: check /dev/input/* modification time
        stat -c %Y /dev/input/event* 2>/dev/null | sort -n | tail -1 || echo 0
    fi
}

# Function to get current idle time
get_idle_time() {
    local x11_idle=$(get_x11_activity)
    
    if [ -z "$x11_idle" ] || [ "$x11_idle" -eq 0 ]; then
        # Fallback: check /dev/input/ modification times
        local current_time=$(date +%s)
        local last_input_time=$(stat -c %Y /dev/input/event* 2>/dev/null | sort -n | tail -1 || echo $current_time)
        echo $((current_time - last_input_time))
    else
        echo "$x11_idle"
    fi
}

# Main monitoring loop
while true; do
    idle_time=$(get_idle_time)
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log activity check every 5 checks (every 150 seconds) to avoid log spam
    check_count=$((check_count + 1))
    if [ $((check_count % 5)) -eq 0 ]; then
        echo "[$current_time] Idle Time: ${idle_time}s / ${IDLE_TIMEOUT}s" >> "$LOG_FILE"
    fi
    
    # Check if idle timeout exceeded
    if [ "$idle_time" -ge "$IDLE_TIMEOUT" ]; then
        echo "[$current_time] IDLE TIMEOUT REACHED: ${idle_time}s >= ${IDLE_TIMEOUT}s" >> "$LOG_FILE"
        
        # Display warning dialog
        if command -v zenity >/dev/null 2>&1; then
            echo "[$current_time] Displaying shutdown warning dialog..." >> "$LOG_FILE"
            zenity --warning --text="Kasam shutting down in ${WARNING_TIME}s due to inactivity" --timeout=${WARNING_TIME} 2>/dev/null
        else
            echo "[$current_time] Warning: No zenity available, proceeding with shutdown" >> "$LOG_FILE"
            sleep "$WARNING_TIME"
        fi
        
        echo "[$current_time] SHUTDOWN: Initiating system shutdown due to 15min inactivity" >> "$LOG_FILE"
        /sbin/shutdown -h now
        exit 0
    fi
    
    # Sleep before next check
    sleep "$CHECK_INTERVAL"
done
EOF

# Make inactivity monitor executable
RUN chmod +x /usr/local/bin/inactivity-monitor.sh

# Add inactivity monitor to kasm_user crontab to start on reboot
RUN mkdir -p /home/kasm_user && \
    echo '@reboot /usr/local/bin/inactivity-monitor.sh > /tmp/kasam-idle.log 2>&1' | crontab -u kasm_user -

# Ensure proper permissions
RUN chown -R 1000:1000 /home/kasm_user /tmp

EXPOSE 6901
