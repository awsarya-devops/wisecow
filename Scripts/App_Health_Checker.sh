#!/bin/bash
# Application Health Checker Script
# PS2 - Objective 4

# Applications to monitor - add your URLs here
APPS=(
    "wisecow-app|http://localhost:4499"
    "google|https://www.google.com"
)

# Log file
LOG_FILE="/var/log/app-health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TIMEOUT=10

echo "======================================"
echo " Application Health Checker"
echo " Timestamp: $TIMESTAMP"
echo "======================================"

# Counters
TOTAL=0
UP=0
DOWN=0

check_app() {
    APP_NAME=$1
    APP_URL=$2

    TOTAL=$((TOTAL + 1))

    # Get HTTP status code
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time $TIMEOUT \
        --connect-timeout $TIMEOUT \
        "$APP_URL" 2>/dev/null)

    CURL_EXIT=$?

    echo ""
    echo "--- Checking: $APP_NAME ---"
    echo "URL: $APP_URL"

    # Check if curl failed entirely (timeout/connection refused)
    if [ $CURL_EXIT -ne 0 ]; then
        echo "Status: DOWN ❌"
        echo "Reason: Connection failed or timed out (exit code: $CURL_EXIT)"
        echo "[$TIMESTAMP] [DOWN] $APP_NAME ($APP_URL) - Connection failed" >> $LOG_FILE
        DOWN=$((DOWN + 1))
        return
    fi

    echo "HTTP Status Code: $HTTP_STATUS"

    # Evaluate HTTP status code
    if [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 300 ]]; then
        echo "Status: UP ✅"
        echo "[$TIMESTAMP] [UP] $APP_NAME ($APP_URL) - HTTP $HTTP_STATUS" >> $LOG_FILE
        UP=$((UP + 1))
    elif [[ "$HTTP_STATUS" -ge 300 && "$HTTP_STATUS" -lt 400 ]]; then
        echo "Status: UP ✅ (Redirect)"
        echo "[$TIMESTAMP] [UP] $APP_NAME ($APP_URL) - HTTP $HTTP_STATUS (redirect)" >> $LOG_FILE
        UP=$((UP + 1))
    elif [[ "$HTTP_STATUS" -ge 400 && "$HTTP_STATUS" -lt 500 ]]; then
        echo "Status: DOWN ❌ (Client Error)"
        echo "[$TIMESTAMP] [DOWN] $APP_NAME ($APP_URL) - HTTP $HTTP_STATUS (client error)" >> $LOG_FILE
        DOWN=$((DOWN + 1))
    elif [[ "$HTTP_STATUS" -ge 500 ]]; then
        echo "Status: DOWN ❌ (Server Error)"
        echo "[$TIMESTAMP] [DOWN] $APP_NAME ($APP_URL) - HTTP $HTTP_STATUS (server error)" >> $LOG_FILE
        DOWN=$((DOWN + 1))
    else
        echo "Status: UNKNOWN ⚠️"
        echo "[$TIMESTAMP] [UNKNOWN] $APP_NAME ($APP_URL) - HTTP $HTTP_STATUS" >> $LOG_FILE
        DOWN=$((DOWN + 1))
    fi
}

# Check all applications
for APP in "${APPS[@]}"; do
    APP_NAME=$(echo $APP | cut -d'|' -f1)
    APP_URL=$(echo $APP | cut -d'|' -f2)
    check_app "$APP_NAME" "$APP_URL"
done

# Summary
echo ""
echo "======================================"
echo " Summary"
echo "======================================"
echo " Total Apps Checked : $TOTAL"
echo " UP                 : $UP ✅"
echo " DOWN               : $DOWN ❌"
echo " Log File           : $LOG_FILE"
echo "======================================"
