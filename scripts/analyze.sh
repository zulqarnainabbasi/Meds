#!/usr/bin/env bash
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"
set -euo pipefail

FORMAT="text"
OUTPUT=""
VERBOSE=false
COMPARE_MODE=false

usage() {
    cat << EOF
Usage:
  ./analyze.sh <logfile> [options]

Options:
  --format text|csv
  --output <path>
  --verbose
  --compare <old_log>
  --help
EOF
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "[INFO] $1"
    fi
}

error_exit() {
    echo "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

LOGFILE="$1"
shift

if [[ ! -f "$LOGFILE" ]]; then
    error_exit "Log file not found: $LOGFILE"
fi

OLD_LOG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --compare)
            COMPARE_MODE=true
            OLD_LOG="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            error_exit "Unknown argument: $1"
            ;;
    esac
done

log_verbose "Analyzing $LOGFILE"

TOTAL=$(grep -c "TEST START:" "$LOGFILE" || true)
PASS=$(grep -c "TEST PASS:" "$LOGFILE" || true)
FAIL=$(grep -c "TEST FAIL:" "$LOGFILE" || true)
SKIP=$(grep -c "TEST SKIP:" "$LOGFILE" || true)

PASS_RATE=$(awk "BEGIN { if ($TOTAL == 0) print 0; else printf \"%.2f\", ($PASS/$TOTAL)*100 }")

FAILED_TESTS=$(grep "TEST FAIL:" "$LOGFILE" | awk -F'TEST FAIL: ' '{print $2}' | awk '{print $1}')

TIMES=$(grep -E "TEST PASS:|TEST FAIL:" "$LOGFILE" | grep -oE '[0-9]+\.[0-9]+s' | sed 's/s//')

MIN_TIME=999999
MAX_TIME=0
SUM=0
COUNT=0

while read -r t; do
    [[ -z "$t" ]] && continue

    SUM=$(awk "BEGIN {print $SUM + $t}")

    if awk "BEGIN {exit !($t < $MIN_TIME)}"; then
        MIN_TIME=$t
    fi

    if awk "BEGIN {exit !($t > $MAX_TIME)}"; then
        MAX_TIME=$t
    fi

    COUNT=$((COUNT + 1))
done <<< "$TIMES"

AVG_TIME=$(awk "BEGIN { if ($COUNT == 0) print 0; else printf \"%.2f\", $SUM/$COUNT }")

generate_text_output() {
cat << EOF
=== RISC-V Simulation Log Analysis ===

Log file: $LOGFILE
Analysis date: $(date)

--- Results Summary ---

Total tests: $TOTAL
Passed:      $PASS
Failed:      $FAIL
Skipped:     $SKIP

Pass rate:   ${PASS_RATE}%

--- Failed Tests ---

${FAILED_TESTS:-None}

--- Timing Statistics ---

Min time: ${MIN_TIME}s
Max time: ${MAX_TIME}s
Avg time: ${AVG_TIME}s

--- Verdict: $( [[ $FAIL -eq 0 ]] && echo "PASS" || echo "FAIL" ) ---
EOF
}

generate_csv_output() {
cat << EOF
metric,value
total_tests,$TOTAL
passed,$PASS
failed,$FAIL
skipped,$SKIP
pass_rate,$PASS_RATE
min_time,$MIN_TIME
max_time,$MAX_TIME
avg_time,$AVG_TIME
EOF
}

RESULT=$(
    [[ "$FORMAT" == "csv" ]] \
    && generate_csv_output \
    || generate_text_output
)

[[ -n "$OUTPUT" ]] && echo "$RESULT" > "$OUTPUT" || echo "$RESULT"

if [[ "$COMPARE_MODE" == true ]]; then

    echo
    echo "-- Regression Analysis --"

    OLD_FAILS=$(grep "Test Fail:" "$OLD_LOG" | awk '{print $5}')
    NEW_FAILS=$(grep "Test Fail:" "$LOGFILE" | awk '{print $5}')

    REGRESSION_FOUND=false

    for test in $NEW_FAILS; do

        if ! echo "$OLD_FAILS" | grep -q "^${test}$"; then
            echo -e "${RED}NEW REGRESSION:${NC} $test"
            REGRESSION_FOUND=true
        fi

    done

    [[ "$REGRESSION_FOUND" == false ]] \
        && echo -e "${GREEN}No new regressions detected.${NC}"

fi

exit $([[ $FAIL -eq 0 ]] && echo 0 || echo 1)