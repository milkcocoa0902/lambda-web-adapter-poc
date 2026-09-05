#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_TAG="${1:?Usage: $0 IMAGE_TAG}"

ECR_REPOSITORY_URL="$(terraform -chdir="${ROOT_DIR}/terraform/01_bootstrap" output -raw ecr_repository_url)"
AWS_REGION="$(terraform -chdir="${ROOT_DIR}/terraform/01_bootstrap" output -raw aws_region)"
ECR_REGISTRY="${ECR_REPOSITORY_URL%%/*}"
IMAGE_URI="${ECR_REPOSITORY_URL}:${IMAGE_TAG}"

aws ecr get-login-password --region "${AWS_REGION}" |
  docker login --username AWS --password-stdin "${ECR_REGISTRY}"

docker build --platform linux/amd64 --tag "${IMAGE_URI}" "${ROOT_DIR}/app"
docker push "${IMAGE_URI}"

printf '%s\n' "${IMAGE_URI}"
