#!/usr/bin/env bash

current_directory=$(dirname $0)
env_file=$current_directory/../../.env

if [ -f $env_file ]
then
    source $env_file
fi

cat <<< "
CODE_SIGN_IDENTITY=$CODE_SIGN_IDENTITY
PROVISIONING_PROFILE_SPECIFIER=$PROVISIONING_PROFILE_SPECIFIER
" | tee $current_directory/Config.release.xcconfig
