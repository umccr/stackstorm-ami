#!/bin/bash
set -e

mkdir -p ~/.aws

cat > ~/.aws/credentials << EOL
[default]
aws_access_key_id     = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL

cat > ~/.aws/config << EOL
[profile packer]
role_arn       = arn:aws:iam::472057503814:role/ops-admin
source_profile = default
region         = ap-southeast-2
EOL
