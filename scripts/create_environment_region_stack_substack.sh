#!/usr/bin/env bash
set -e

if [ $# -ne 4 ]
then
  echo "Usage: $0 <environment_name> <region> <stack_name> <substack_name>"
  exit
fi

# Make sure we're in our terraform top-level directory which we must be for this to work properly
if [[ ! -f "$PWD/globals.auto.tf" || -L "$PWD/globals.auto.tf" ]]; then
  echo "ERROR: We are in the wrong folder, must be in the root of your Terraform folder"
  exit 1
fi

# Grab our env name from the CLI args
ENVNAME=$1
REGION=$2
STACKNAME=$3
SUBSTACKNAME=$4

# Check if envname exists
if [ ! -d "$PWD/$ENVNAME" ]; then
  echo "ERROR: Environment $ENVNAME does not exist!"
  exit 1
fi

# Check if region exists in envname
if [ ! -d "$PWD/$ENVNAME/$REGION" ]; then
  echo "ERROR: Region $REGION does not exist inside of Environment $ENVNAME!"
  exit 1
fi

# Check if stack exists in envname
if [ ! -d "$PWD/$ENVNAME/$REGION/$STACKNAME" ]; then
  echo "ERROR: Stack name $STACKNAME does not exist inside of Environment $ENVNAME Region $REGION!"
  exit 1
fi

# Check if this stack is setup to have substacks
if [ ! -h "$PWD/$ENVNAME/$REGION/$STACKNAME/zzzzz-do-not-run-terraform-here.tf" ]; then
  echo "ERROR: Stack name $STACKNAME is not set up to be substacked"
  exit 1
fi

# Check if stack already exists in envname/region
if [ -d "$PWD/$ENVNAME/$REGION/$STACKNAME/$SUBSTACKNAME" ]; then
  echo "ERROR: Substack name $SUBSTACKNAME in Stack $STACKNAME in Environment/Region $ENVNAME/$REGION already exists!"
  exit 1
fi

OLDPWD=$PWD

# And do what we need
echo "Creating substack $SUBSTACKNAME in $ENVNAME/$REGION/$STACKNAME "

# Create stack folder
echo "  Creating folder: $ENVNAME/$REGION/$STACKNAME/$SUBSTACKNAME"
echo "  Entering directory: $ENVNAME/$REGION/$STACKNAME/$SUBSTACKNAME"
mkdir "$ENVNAME/$REGION/$STACKNAME/$SUBSTACKNAME"
cd "$ENVNAME/$REGION/$STACKNAME/$SUBSTACKNAME"

# Create necessary files inside stack
echo "    Symlinking: ../../../.terraform-version"
ln -s ../../../../.terraform-version
echo "    Symlinking: ../../../globals.auto.tf"
ln -s ../../../../globals.auto.tf
echo "    Symlinking: ../../../globals.auto.tfvars"
ln -s ../../../../globals.auto.tfvars

echo "    Symlinking: ../../$ENVNAME.auto.tf"
ln -s ../../../$ENVNAME.auto.tf
echo "    Symlinking: ../../$ENVNAME.auto.tfvars"
ln -s ../../../$ENVNAME.auto.tfvars

echo "    Symlinking: ../${ENVNAME}__regional.auto.tf"
ln -s ../../${ENVNAME}__regional.auto.tf
echo "    Symlinking: ../${ENVNAME}__regional.auto.tfvars"
ln -s ../../${ENVNAME}__regional.auto.tfvars

echo "    Symlinking: ../${STACKNAME}.auto.tf"
ln -s ../${STACKNAME}.auto.tf
echo "    Symlinking: ../${STACKNAME}.auto.tfvars"
ln -s ../${STACKNAME}.auto.tfvars

echo "    Creating terraform.tfvars"
echo "" > terraform.tfvars

# Check if we have a template for this, lets pre-symlink those into place
if [ -d "$OLDPWD/templates/$SUBSTACKNAME" ]; then
  echo "Template $SUBSTACKNAME found, setting up template..."
  for TEMPLATE_FILE in $(ls ../../../../templates/$SUBSTACKNAME | tr '/' ' '); do
    echo "Symlinking template: $TEMPLATE_FILE"
    ln -s ../../../../templates/$SUBSTACKNAME/$TEMPLATE_FILE
  done
  echo "Completed setting up template for $SUBSTACKNAME"
fi

# Check if we have a "variables.tf" which is a standard file which must be in place setting up the stack name and version
if [ ! -f "./variables.tf" ] && [ ! -L "./variables.tf" ]; then
  echo "variables.tf does not exist, creating..."

  VARIABLES_TF_CONTENTS=$(cat << EOF
# Every stack has a name and a version, this is used in all the tags
locals {
    # The unique name of this stack.  This is typically copied from the folder name in our "templates" folder
    stack_name = "$STACKNAME-$SUBSTACKNAME"
    # The version of this stack name, should always be 3 octets, major.minor.sub
    stack_version = "1.0.0"
}

# This grabs our global remote state for the SNS to slack topic, generally all stacks import the global state
# Of course, if you want comment this out, but generally global is always setup first before any stacks are deployed
data "terraform_remote_state" "global" {
    backend = "s3"
    config = {
        bucket = "terraform-deploy-fragments-\${data.aws_caller_identity.current.account_id}-\${var.aws_region}"
        key = "\${var.client_name_short}-\${var.environment}-global.tfstate"
        region=var.aws_region
    }
}

# This pulls in our remote vpc stack variables from our project/stage/region vpc
### Uncomment if needed
#data "terraform_remote_state" "vpc" {
#    backend = "s3"
#    config = {
#        bucket = "terraform-deploy-fragments-\${data.aws_caller_identity.current.account_id}-\${var.aws_region}"
#        key = "\${var.client_name_short}-\${var.environment}-vpc.tfstate"
#        region=var.aws_region
#    }
#}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
    source     = "../../../../modules/terraform-tags"
    name       = local.stack_name
    stage      = var.environment
    tags       = tomap({"StackVersion"=local.stack_version}) # Add more in here to add more tags for eg: tenants, or owners, or team names, etc.
}

# This is used in some templates for adding KMS support, and allowing eg: your application/role for this stack to allow it to read/write to that KMS
# Ignore/delete this if your stack isn't doing anything with KMS
locals {
    additional_kms_key_admins = []
    additional_kms_key_users = []
}
EOF
)
  echo "$VARIABLES_TF_CONTENTS" > ./variables.tf
fi

echo ""
echo "Creation complete: $ENVNAME/$REGION/$STACKNAME/$SUBSTACKNAME"
echo ""
