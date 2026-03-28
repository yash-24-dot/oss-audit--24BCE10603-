
#!/bin/bash
# =============================================================

# Course  : Open Source Software — VITyarthi
# Author  : Yash Tripathi | Roll No: 24BCE10603
# Usage   : ./script4_log_analyzer.sh /path/to/logfile [keyword]
# Example : ./script4_log_analyzer.sh /var/log/syslog error
# =============================================================
 
# ANSI colours
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'
 
# Command-line arguments
# $1 is the log file path; $2 is the keyword (default: "error")
LOGFILE=$1
KEYWORD=${2:-"error"}
 
# Counter and retry variables
COUNT=0
RETRY_LIMIT=3
RETRY_COUNT=0
 
echo -e "${BLUE}============================================================${NC}"
echo -e "${BOLD}         LOG FILE ANALYZER                                  ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
 
# Validate that the user actually gave us a file path
if [ -z "$LOGFILE" ]; then
    echo -e "  ${RED}ERROR:${NC} No log file specified."
    echo -e "  Usage  : $0 /path/to/logfile [keyword]"
    echo -e "  Example: $0 /var/log/syslog error"
    exit 1
fi
 
# Check the file exists — [ -f ] tests for a regular file
if [ ! -f "$LOGFILE" ]; then
    echo -e "  ${RED}ERROR:${NC} '$LOGFILE' not found."
    echo -e "  Check the path and try again."
    exit 1
fi
 
echo -e "  ${CYAN}Log File :${NC} $LOGFILE"
echo -e "  ${CYAN}Keyword  :${NC} '${YELLOW}$KEYWORD${NC}'"
echo ""
echo -e "${BLUE}------------------------------------------------------------${NC}"
 
# Do-while style retry loop — Bash has no native do-while,
# so we use "while true" and break out once the file has content.
# This handles the edge case where a log file exists but is empty.
while true; do
    if [ -s "$LOGFILE" ]; then
        break   # File is non-empty — proceed
    fi
 
    RETRY_COUNT=$((RETRY_COUNT + 1))
 
    if [ $RETRY_COUNT -ge $RETRY_LIMIT ]; then
        echo -e "  ${YELLOW}WARNING:${NC} File appears empty after $RETRY_LIMIT checks."
        echo -e "  Continuing — result will show 0 matches."
        break
    fi
 
    echo -e "  File looks empty. Retrying ($RETRY_COUNT/$RETRY_LIMIT)..."
    sleep 1
done
 
echo -e "  Scanning for keyword '${YELLOW}$KEYWORD${NC}'..."
echo ""
 
# while IFS= read -r reads the log file one line at a time.
# IFS= prevents leading/trailing whitespace from being stripped.
# -r prevents backslashes from being interpreted as escape characters.
while IFS= read -r LINE; do
    # grep -iq does a case-insensitive quiet match on each line
    if echo "$LINE" | grep -iq "$KEYWORD"; then
        COUNT=$((COUNT + 1))   # arithmetic expansion increments the counter
    fi
done < "$LOGFILE"
 
# Print the summary
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e "  ${GREEN}SCAN SUMMARY${NC}"
echo -e "${BLUE}------------------------------------------------------------${NC}"
 
if [ $COUNT -gt 0 ]; then
    echo -e "  Keyword '${YELLOW}$KEYWORD${NC}' found ${GREEN}${BOLD}$COUNT${NC} time(s) in:"
    echo -e "  $LOGFILE"
    echo ""
    echo -e "  ${CYAN}Last 5 matching lines:${NC}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    # grep + tail extracts the last 5 lines containing the keyword
    grep -i "$KEYWORD" "$LOGFILE" | tail -5 | while IFS= read -r MATCH; do
        echo -e "  ${YELLOW}>>>${NC} $MATCH"
    done
else
    echo -e "  Keyword '${YELLOW}$KEYWORD${NC}' was ${RED}not found${NC} in $LOGFILE."
    echo -e "  Try a different keyword: ${CYAN}warning, fail, denied, critical${NC}"
fi
 
echo ""
echo -e "${BLUE}============================================================${NC}"
