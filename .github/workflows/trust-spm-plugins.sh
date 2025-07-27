#!/usr/bin/env bash

current_directory=$(dirname $0)
security_directory=~/Library/org.swift.swiftpm/security

cp $current_directory/../../Fyreplace.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved /tmp/packages.json
mkdir -p $security_directory

node $current_directory/get-fingerprint.js \
    swift-openapi-generator:OpenAPIGenerator \
    grpc-swift:GRPCSwiftPlugin \
    swift-protobuf:SwiftProtobufPlugin \
| tee $security_directory/plugins.json
