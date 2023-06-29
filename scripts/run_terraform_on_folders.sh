#!/usr/bin/env bash
###################
# This simple helper scans for all folders in a current folder and
# runs `terraform <input args>` within that folder.  So to run a
# terraform plan on all subfolders, go into the folder you wish, eg:
#   cd master/us-east-1
#   ../../scripts/run_terraform_on_folders.sh
#
# Written by Farley <farley@neonsurge.com>
###################

# Save the PWD
CURRENT_WORKING_DIRECTORY=`pwd`

######
# Config env vars
#####
# Set this to false when running this command from CI systems
INTERACTIVE=${INTERACTIVE-true}
# Set this to what to do if non-interactive, to "continue" or "stop"
NON_INTERACTIVE_DEFAULT_ACTION=${NON_INTERACTIVE_DEFAULT_ACTION-continue}

# Primary loop logic
for CURRENT_FOLDER in $(ls -d */ | grep -Evi "unused|templates|examples" | tr '/' ' '); do
    cd $CURRENT_WORKING_DIRECTORY
    echo "Entering folder: $CURRENT_FOLDER ..."
    cd $CURRENT_FOLDER
    echo "Running command: terraform $@"
    terraform $@
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then

      echo "The terraform command on $CURRENT_FOLDER failed with exit code: $EXIT_CODE"

      # Validating if we're in non-interactive mode and handling the logic accordingly
      if [ $INTERACTIVE != true ]; then
        echo "non-interactive"
        if [ "$NON_INTERACTIVE_DEFAULT_ACTION" == "continue" ]; then
          echo "Using NON_INTERACTIVE_DEFAULT_ACTION to continue processing..."
          continue
        else
          echo "Using NON_INTERACTIVE_DEFAULT_ACTION to stop processing..."
          exit $EXIT_CODE
        fi
      fi

      # If we're in interactive mode, we'll ask the user if they want to continue
      while true; do
          read -p "Would you like to continue?  (y/n): " INPUT_TEXT
          if [ "$INPUT_TEXT" == "y" ]; then
            break
          elif [ "$INPUT_TEXT" == "n" ]; then
            exit $EXIT_CODE
          fi
      done
    fi

done
