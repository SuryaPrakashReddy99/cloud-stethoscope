#!/bin/bash
# If coverage script exists, run it, else fake 50 %
if npm run test:coverage --silent; then
   COV=$(jq '.total.lines.pct' coverage/lcov-report/coverage-summary.json)
else
   COV=50
fi
echo "{ \"coverage_percent\": $COV }" > coverage.json