#!/usr/bin/env bash

export PATH="$PATH:/opt/homebrew/bin"

if [[ $CONFIGURATION = "Debug" ]]
then
    echo "Skipping Sentry sources upload"
elif [[ -n $SENTRY_AUTH_TOKEN ]]
then
    ERROR=$(sentry-cli debug-files upload \
        --org $SENTRY_ORG \
        --project $SENTRY_PROJECT \
        --auth-token $SENTRY_AUTH_TOKEN \
        --include-sources "$DWARF_DSYM_FOLDER_PATH" \
        --force-foreground 2>&1 >/dev/null)

    if [[ $? -ne 0 ]]
    then
        echo "error: sentry-cli - $ERROR"
        exit 1
    fi
fi
