#!/usr/bin/env bash
set -e

if [ $# -ne 2 ]
then
  echo "Usage: $0 <environment_name> <region>"
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

# Check if envname exists
if [ ! -d "$PWD/$ENVNAME" ]; then
  echo "ERROR: Environment $ENVNAME does not exist!"
  exit 1
fi

# Check if region exists in envname
if [ -d "$PWD/$ENVNAME/$REGION" ]; then
  echo "ERROR: Region $REGION already exists inside of Environment $ENVNAME!"
  exit 1
fi

# TODO: Check if region is valid from list of AWS's regions?

# And do what we need
echo "Creating region in $ENVNAME: $REGION"

# Create region folder
mkdir "$ENVNAME/$REGION"

# Making this folder unable to run terraform intentionally
echo "  Symlinking: ../zzzzz-do-not-run-terraform-here.tf"
cd "$ENVNAME/$REGION"
ln -s ../zzzzz-do-not-run-terraform-here.tf
cd ../..

# Create necessary files inside TLD
echo "  Creating regional file: $ENVNAME/$REGION/${ENVNAME}__regional.auto.tf"
echo "provider \"aws\" {" > $ENVNAME/$REGION/${ENVNAME}__regional.auto.tf
echo "	region  = \"$REGION\"" >> $ENVNAME/$REGION/${ENVNAME}__regional.auto.tf
echo "}" >> $ENVNAME/$REGION/${ENVNAME}__regional.auto.tf

echo "  Creating regional file: $ENVNAME/$REGION/${ENVNAME}__regional.auto.tfvars"
echo "" > $ENVNAME/$REGION/${ENVNAME}__regional.auto.tfvars
echo ""
echo "HINT: You should now typically proceed with running something like..."
echo "      './scripts/create_environment_region_stack.sh $ENVNAME $REGION vpc'"
echo "      to create an VPC for you in your region so you can deploy/create"
echo "      resources into it"
echo ""
