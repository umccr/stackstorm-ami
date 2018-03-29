#!/bin/bash
set -e

export AWS_REGION=ap-southeast-2

temp_role=$(aws sts assume-role --role-arn "arn:aws:iam::472057503814:role/ops_admin_no_mfa" --role-session-name "temp_session")

export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq .Credentials.SessionToken | xargs)

env | grep AWS # TODO: test this
