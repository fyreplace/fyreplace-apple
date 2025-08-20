#!/usr/bin/env bash

set -e

export PATH="$PATH:/opt/homebrew/bin"

if [[ $CONFIGURATION = "Debug" ]]
then
    echo "Skipping Sentry sources upload"
elif [[ -n $SENTRY_AUTH_TOKEN ]]
then
    sentry-cli debug-files upload --include-sources "$DWARF_DSYM_FOLDER_PATH"
fi
