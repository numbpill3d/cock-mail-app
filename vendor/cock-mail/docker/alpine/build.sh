#!/bin/bash

TAG="local.local/alpine:mini"

deps="docker"
for dep in $deps
do
    type $dep >/dev/null 2>/dev/null
    if [[ $? -ne 0 ]]
    then
        echo "Dependency not found: $dep"
        echo "Dependencies: $dependencies"
        exit 1
    fi
done

set -e

docker build $@ -t "$TAG" .
