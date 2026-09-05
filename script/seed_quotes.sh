#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${ROOT_DIR}/terraform/02_application"
QUOTES_FILE="${ROOT_DIR}/app/data/quotes.json"

TABLE_NAME="$(terraform -chdir="${TERRAFORM_DIR}" output -raw quotes_table_name)"
AWS_REGION="$(terraform -chdir="${TERRAFORM_DIR}" output -raw aws_region)"
QUOTE_COUNT="$(jq 'length' "${QUOTES_FILE}")"

for ((index = 0; index < QUOTE_COUNT; index++)); do
  item="$(jq -c --argjson index "${index}" --arg id "$((index + 1))" '
    .[$index] | {
      id: {N: $id},
      category: {S: .category},
      quote: {S: .quote}
    }
  ' "${QUOTES_FILE}")"

  aws dynamodb put-item \
    --table-name "${TABLE_NAME}" \
    --item "${item}" \
    --region "${AWS_REGION}" >/dev/null
done

metadata="$(jq -cn --arg count "${QUOTE_COUNT}" '{id: {N: "0"}, count: {N: $count}}')"
aws dynamodb put-item \
  --table-name "${TABLE_NAME}" \
  --item "${metadata}" \
  --region "${AWS_REGION}" >/dev/null
