#!/bin/bash

# Kasam Inactivity Monitor Script
# Monitors X11 and /dev/input/* for activity
# Triggers auto-shutdown after 900 seconds (15 minutes) of inactivity
# Features: Comprehensive activity logging, configurable timeout, graceful shutdown

IDLE_TIMEOUT=${IDLE_TIMEOUT:-900}  # 15 minutes in seconds (900)
WARNING_TIME=${WARNING_TIME:-60}    # 60 seconds warning before shutdown
CHECK_INTERVAL=30                   # Check every 30 seconds
LOG_FILE="/tmp/kasam-idle.log"

# Set up signal handlers for graceful exit
trap 'echo "[$(date '+%Y-%m-%d %H:%M:%S')] Inactivity monitor terminated" >> "$LOG_FILE"; exit 0' SIGTERM SIGINT

# Initialize log file with comprehensive header
{
    echo "==========================================================="
    echo "Kasam Inactivity Monitor - Activity Log"
    echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "==========================================================="
    echo "Configuration:"
    echo "  - Idle Timeout: ${IDLE_TIMEOUT} seconds (15 minutes)"
    echo "  - Warning Time: ${WARNING_TIME} seconds before shutdown"
    echo "  - Check Interval: ${CHECK_INTERVAL} seconds"
    echo "  - Monitor PID: $$"
    echo "  - Log File: $LOG_FILE"
    echo "==========================================================="
    echo ""
} >> "$LOG_FILE"

# Function to get last activity time from X11 (most reliable)
get_x11_activity() {
    # Try xprintidle first (most accurate)
    if command -v xprintidle >/dev/null 2>&1; then
        local idle_ms=$(xprintidle 2>/dev/null || echo 0)
        echo $((idle_ms / 1000))  # Convert milliseconds to seconds
        return 0
    fi
    
    # Fallback to /dev/input/* monitoring
    return 1
}

# Function to get idle time from /dev/input/* events
get_input_device_activity() {
    if ! [ -d "/dev/input" ]; then
        return 1
    fi
    
    local current_time=$(date +%s)
    local last_activity_time=0
    
    # Check all input event files for modification time
    for event_file in /dev/input/event*; do
        if [ -e "$event_file" ]; then
            local mod_time=$(stat -c %Y "$event_file" 2>/dev/null)
            if [ -n "$mod_time" ] && [ "$mod_time" -gt "$last_activity_time" ]; then
                last_activity_time=$mod_time
            fi
        fi
    done
    
    if [ "$last_activity_time" -gt 0 ]; then
        echo $((current_time - last_activity_time))
        return 0
    fi
    
    return 1
}

# Main function to determine current idle time
get_idle_time() {
    # Try X11 first (most reliable for desktop environments)
    if idle_time=$(get_x11_activity); then
        echo "$idle_time"
        return 0
    fi
    
    # Fallback to /dev/input/* monitoring
    if idle_time=$(get_input_device_activity); then
        echo "$idle_time"
        return 0
    fi
    
    # If all methods fail, assume active (return 0)
    echo 0
    return 0
}

# Counter for logging
check_count=0
last_idle_logged=0

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Monitor initialized and running..." >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Main monitoring loop
while true; do
    idle_time=$(get_idle_time)
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    check_count=$((check_count + 1))
    
    # Log status every 5 checks (every 150 seconds = 2.5 min) to avoid log spam
    if [ $((check_count % 5)) -eq 0 ]; then
        idle_percent=$((idle_time * 100 / IDLE_TIMEOUT))
        echo "[$current_time] Idle: ${idle_time}s / ${IDLE_TIMEOUT}s (${idle_percent}%) [Check #$check_count]" >> "$LOG_FILE"
        last_idle_logged=$idle_time
    fi
    
    # Warning at 75% of timeout
    if [ "$idle_time" -ge $((IDLE_TIMEOUT * 3 / 4)) ] && [ "$idle_time" -lt $((IDLE_TIMEOUT)) ] && [ $((check_count % 10)) -eq 0 ]; then
        idle_percent=$((idle_time * 100 / IDLE_TIMEOUT))
        echo "[$current_time] WARNING: Approaching idle timeout (${idle_percent}%)" >> "$LOG_FILE"
    fi
    
    # Check if idle timeout exceeded
    if [ "$idle_time" -ge "$IDLE_TIMEOUT" ]; then
        echo "" >> "$LOG_FILE"
        echo "[$current_time] ========== IDLE TIMEOUT TRIGGERED =========" >> "$LOG_FILE"
        echo "[$current_time] Idle Time: ${idle_time}s has exceeded ${IDLE_TIMEOUT}s" >> "$LOG_FILE"
        echo "[$current_time] Last Activity: $((($(date +%s) - idle_time) | xargs date -d @)" >> "$LOG_FILE" 2>/dev/null || echo "[$current_time] Last Activity: Unknown" >> "$LOG_FILE"
        
        # Display zenity warning dialog
        if command -v zenity >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
            echo "[$current_time] Displaying zenity shutdown warning dialog (${WARNING_TIME}s)..." >> "$LOG_FILE"
            zenity --warning \
                --text="Kasam shutting down in ${WARNING_TIME}s due to inactivity\n\nMove mouse or press key to cancel" \
                --timeout=${WARNING_TIME} \
                --width=400 \
                2>/dev/null
            zenity_exit=$?
            
            if [ $zenity_exit -eq 0 ]; then
                echo "[$current_time] User dismissed warning dialog" >> "$LOG_FILE"
            else
                echo "[$current_time] Warning dialog timed out or closed" >> "$LOG_FILE"
            fi
        else
            echo "[$current_time] Zenity unavailable, waiting ${WARNING_TIME}s before shutdown..." >> "$LOG_FILE"
            sleep "$WARNING_TIME"
        fi
        
        echo "[$current_time] SHUTDOWN INITIATED: System shutting down due to 15-minute inactivity" >> "$LOG_FILE"
        echo "[$current_time] Shutdown Time: $(date '+%Y-%m-%d %H:%M:%S'Z)" >> "$LOG_FILE"
        echo "[$current_time] =========================================" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        
        # Execute shutdown
        /sbin/shutdown -h now "Kasam auto-shutdown: 15 minutes inactivity reached"
        exit 0
    fi
    
    # Sleep before next check
    sleep "$CHECK_INTERVAL"
done
