#!/usr/bin/env bash
# Deploy the data portal to s3://sustainable-fsa/ and invalidate CloudFront.
#
# Usage:
#   ./deploy.sh                 # uses AWS_PROFILE if set, else "mco"
#   AWS_PROFILE=other ./deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

: "${AWS_PROFILE:=mco}"
export AWS_PROFILE

BUCKET="s3://sustainable-fsa"
DISTRIBUTION="E1BNL6ONVN84RI"

aws sts get-caller-identity > /dev/null ||
  { echo "AWS credentials unavailable — run: aws sso login --profile $AWS_PROFILE" >&2; exit 1; }

aws s3 cp index.html "$BUCKET/index.html" \
  --content-type "text/html; charset=utf-8" --cache-control "max-age=300"

aws s3 cp assets/sustainable-fsa-banner.svg "$BUCKET/sustainable-fsa-banner.svg" \
  --content-type "image/svg+xml" --cache-control "max-age=86400"

aws s3 cp assets/MCO_logo.svg "$BUCKET/MCO_logo.svg" \
  --content-type "image/svg+xml" --cache-control "max-age=86400"

aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION" \
  --paths "/index.html" "/" --query "Invalidation.{Id:Id,Status:Status}" --output table

echo "Deployed. https://data.sustainable-fsa.com/"
