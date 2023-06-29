#!/usr/bin/env bash
set -e

if [ $# -ne 1 ]
then
  echo "Usage: $0 <environment_name>"
  exit
fi

# Make sure we're in our terraform top-level directory which we must be for this to work properly
if [[ ! -f "$PWD/globals.auto.tf" || -L "$PWD/globals.auto.tf" ]]; then
  echo "ERROR: We are in the wrong folder, must be in the root of your Terraform folder"
  exit 1
fi
OLDPWD=${PWD}

# Grab our env name from the CLI args
ENVNAME=$1

# And do what we need
echo "Creating env (account): $ENVNAME"

# Create TLD
mkdir $ENVNAME

# Making this folder unable to run terraform intentionally
echo "  Symlinking: ../zzzzz-do-not-run-terraform-here.tf"
cd $ENVNAME
ln -s ../zzzzz-do-not-run-terraform-here.tf
cd ..

# Create necessary files inside TLD
echo "  Creating account-level file: $ENVNAME/$ENVNAME.auto.tf"

echo '# Put account-specific variables definitions here' > $ENVNAME/$ENVNAME.auto.tf
echo '# variable "account_level_var_here" {  # For example...' >> $ENVNAME/$ENVNAME.auto.tf
echo '#     type     = bool' >> $ENVNAME/$ENVNAME.auto.tf
echo '#     default  = false' >> $ENVNAME/$ENVNAME.auto.tf
echo '# }' >> $ENVNAME/$ENVNAME.auto.tf

echo "  Creating account-level file: $ENVNAME/$ENVNAME.auto.tfvars"
echo "# Put account-specific variables here" > $ENVNAME/$ENVNAME.auto.tfvars
echo "environment = \"$ENVNAME\"" >> $ENVNAME/$ENVNAME.auto.tfvars

# Creating global stack
echo "  Creating global stack in $ENVNAME..."
mkdir $ENVNAME/global
cd $ENVNAME/global

echo "    Symlinking: ../../.terraform-version"
ln -s ../../.terraform-version
echo "    Symlinking: ../../globals.auto.tf"
ln -s ../../globals.auto.tf
echo "    Symlinking: ../../globals.auto.tfvars"
ln -s ../../globals.auto.tfvars
echo "    Symlinking: ../$ENVNAME.auto.tf"
ln -s ../$ENVNAME.auto.tf
echo "    Symlinking: ../$ENVNAME.auto.tfvars"
ln -s ../$ENVNAME.auto.tfvars

echo "    Symlinking: ../../templates/global/variables.tf"
ln -s ../../templates/global/variables.tf
echo "    Symlinking: ../../templates/global/account-alias.tf"
ln -s ../../templates/global/account-alias.tf
echo "    Symlinking: ../../templates/global/password-policy.tf"
ln -s ../../templates/global/password-policy.tf

echo "    Creating: terraform.tfvars"
echo "" > terraform.tfvars


echo "DONE"
echo ""
echo "NOTE: If this is your master account, you will likely want to symlink..."
echo "      ln -s ../../templates/global/require-mfa.tf"
echo "      ln -s ../../templates/global/users.tf"
echo "      ln -s ../../templates/global/admins.tf"
echo ""
echo "NOTE: If you wish to have audit logs on this account..."
echo "      ln -s ../../templates/global/cloudtrail.tf"

echo "NOTE: If you wish to have guardduty on this account..."
echo "      ln -s ../../templates/global/guardduty.tf"
echo ""

echo "HINT: After any additional symlinks Now you'll typically want to go into"
echo "      the $ENVNAME/global folder and 'terraform init && terraform apply'"
echo "      then proceed with ./scripts/create_environment_region.sh $ENVNAME us-east-1"
echo "      (or whatever region you wish to setup/use)"
echo ""
