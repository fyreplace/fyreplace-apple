#!/usr/bin/env bash

current_directory=$(dirname $0)
env_file=$current_directory/../.env

if [ -f $env_file ]
then
    source $env_file
fi

#========#
# Common #
#========#

echo "Generating common config..."

branch=$(git rev-parse --abbrev-ref HEAD)
commit_count=$(git rev-list --count HEAD)
version=$(git describe --tags)
version_string=$(echo $version | sed -E 's/^v([0-9]+.[0-9]+.[0-9]+)(-.+)?/\1/')

case $version in
*-*)
    version_number_suffix=0
    major=$(echo $version_string | cut -d '.' -f 1)
    minor=$(echo $version_string | cut -d '.' -f 2)
    patch=$(echo $version_string | cut -d '.' -f 3)
    minor=$((minor + 1))
    version_string="$major.$minor.$patch"
    ;;
*)
    version_number_suffix=3
    ;;
esac

case $branch in
hotfix/*)
    version_number_suffix=2
    version_string=${branch/"hotfix/"/}
    ;;
release/*)
    version_number_suffix=1
    version_string=${branch/"release/"/}
    ;;
esac

cat <<< "
SLASH=/
DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM
CURRENT_PROJECT_VERSION=$commit_count.$version_number_suffix
MARKETING_VERSION=$version_string
SENTRY_DSN=${SENTRY_DSN//\//\$(SLASH)}
SENTRY_ORG=$SENTRY_ORG
SENTRY_PROJECT=$SENTRY_PROJECT
SENTRY_AUTH_TOKEN=$SENTRY_AUTH_TOKEN
" > $current_directory/Config.xcconfig

#=========#
# Release #
#=========#

echo "Generating release config..."

cat <<< "
#include \"Config.xcconfig\"

CODE_SIGN_IDENTITY=$CODE_SIGN_IDENTITY
PROVISIONING_PROFILE_SPECIFIER=$PROVISIONING_PROFILE_SPECIFIER
" > $current_directory/Config.release.xcconfig
