#!/usr/bin/env bash

current_directory=$(dirname $0)
security_directory=~/Library/org.swift.swiftpm/security

cp $current_directory/../../Fyreplace.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved /tmp/packages.json
mkdir -p $security_directory

cat <<< '
[
  {
    "fingerprint" : "'$(node $current_directory/get-fingerprint.js swift-openapi-generator)'",
    "packageIdentity" : "swift-openapi-generator",
    "targetName" : "OpenAPIGenerator"
  }
]
' | tee $security_directory/plugins.json
