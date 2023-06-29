#!/bin/bash

# This shell script queries AWS in a tricky way to generate a JSON output of the SSL Certificate via openssl
# Scraped from various places on the internet, edited for correctness and currently authored and placed here by Farley
# See: https://github.com/terraform-providers/terraform-provider-aws/issues/10104
# Note: Newer versions of terraform do support pulling this directly, but it is not supported on older versions, so we should just keep this for backwards compatibility

# Fetch and parse result
THUMBPRINT=$(echo | openssl s_client -servername oidc.eks.$1.amazonaws.com -showcerts -connect oidc.eks.$1.amazonaws.com:443 2>&- | tail -r | sed -n '/-----END CERTIFICATE-----/,/-----BEGIN CERTIFICATE-----/p; /-----BEGIN CERTIFICATE-----/q' | tail -r | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
# Convert to JSON (not really accurate because this wont escape everything, but it works for this simple input)
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
# Echo so Terraform can read and parse it
echo $THUMBPRINT_JSON
