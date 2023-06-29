#!/bin/bash

# This will only work for farleyfarley, whose username this is encrypted from
secret_key=$(echo $1 | base64 --decode | keybase pgp decrypt)
echo -n "{\"secret_key\":\"${secret_key}\"}"
