#!/usr/bin/env bash

touch Fyreplace/Info.plist
cd protos

for p in $(ls)
do
    touch ${p/.proto/.pb.swift}
    touch ${p/.proto/.grpc.swift}
done
