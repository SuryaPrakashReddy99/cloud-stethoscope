#!/bin/bash
# Count GPL (bad) and MIT (good) licences
npx license-checker --json > licenses.json || true
GPL=$(jq '[.[].licenses | select(. | contains("GPL"))] | length' licenses.json)
MIT=$(jq '[.[].licenses | select(. | contains("MIT"))] | length' licenses.json)
echo "{ \"gpl_count\": $GPL, \"mit_count\": $MIT }" > license.json