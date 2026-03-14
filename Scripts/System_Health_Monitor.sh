#!/bin/bash
# System Health Monitoring Script
# PS2 - Objective 1

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Log file
LOG_FILE="/var/log/system-health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "======================================"
echo " System Health Monitor - $TIMESTAMP"
echo "======================================"

# Function to log and print
log_alert() {
    echo "[ALERT] $1"
    echo "[$TIMESTAMP] [ALERT] $1" >> $LOG_FILE
}

log_ok() {
    echo "[OK] $1"
    echo "[$TIMESTAMP] [OK] $1" >> $LOG_FILE
}

# ---- CPU Usage ----
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
echo ""
echo "--- CPU Usage ---"
echo "Current CPU Usage: ${CPU_USAGE}%"
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    log_alert "CPU usage is HIGH: ${CPU_USAGE}% (Threshold: ${CPU_THRESHOLD}%)"
else
    log_ok "CPU usage is normal: ${CPU_USAGE}%"
fi

# ---- Memory Usage ----
MEMORY_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEMORY_USED=$(free -m | awk '/Mem:/ {print $3}')
MEMORY_USAGE=$(( MEMORY_USED * 100 / MEMORY_TOTAL ))
echo ""
echo "--- Memory Usage ---"
echo "Total: ${MEMORY_TOTAL}MB | Used: ${MEMORY_USED}MB | Usage: ${MEMORY_USAGE}%"
if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    log_alert "Memory usage is HIGH: ${MEMORY_USAGE}% (Threshold: ${MEMORY_THRESHOLD}%)"
else
    log_ok "Memory usage is normal: ${MEMORY_USAGE}%"
fi

# ---- Disk Usage ----
echo ""
echo "--- Disk Usage ---"
while IFS= read -r line; do
    DISK_USAGE=$(echo "$line" | awk '{print $5}' | cut -d% -f1)
    MOUNT=$(echo "$line" | awk '{print $6}')
    echo "Mount: $MOUNT | Usage: ${DISK_USAGE}%"
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        log_alert "Disk usage HIGH at $MOUNT: ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)"
    else
        log_ok "Disk usage normal at $MOUNT: ${DISK_USAGE}%"
    fi
done < <(df -h | grep '^/dev/' | awk '{print $5, $6}' | sed 's/%//')

# ---- Running Processes ----
echo ""
echo "--- Top 5 Running Processes (by CPU) ---"
ps aux --sort=-%cpu | head -6 | awk '{printf "%-10s %-8s %-8s %s\n", $1, $2, $3, $11}'

# ---- Summary ----
echo ""
echo "======================================"
echo " Health check complete. Log: $LOG_FILE"
echo "======================================"
