#!/bin/bash
# Count high-severity npm audit issues
echo "Running npm audit..."
npm audit --json > audit.json || true  # ignore exit code
HIGH=$(jq '.metadata.vulnerabilities.high // 0' audit.json)
CRITICAL=$(jq '.metadata.vulnerabilities.critical // 0' audit.json)
echo "{ \"security_high\": $HIGH, \"security_critical\": $CRITICAL }" > security.json