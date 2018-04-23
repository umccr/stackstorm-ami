#!/bin/bash -e

# install DataDog Python library
pip install datadog

# Set up
tee ~/.dogrc << END
[Connection]
apikey = ${DATADOG_API_KEY}
appkey = ${DATADOG_APP_KEY}
END

echo "Extracting AMI ID"
ami_id=`grep 'artifact,0,id' packer-build.log | cut -d, -f6 | cut -d: -f2`

echo "Extracted AMI ID: $ami_id. Sending DataDog event..."
dog event post --no_host --tags aws,ami,stackstorm --type travis "New StackStorm AMI created" "$ami_id"
echo "Event successfully sent."
