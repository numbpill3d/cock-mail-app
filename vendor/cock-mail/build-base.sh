#!/bin/bash

cd $(dirname -- "$0")

if [[ ! -d docker/alpine ]]
then
    echo "I can't find the docker/alpine directory :("
    exit 1
fi

pushd "docker/alpine"

bash get.sh
bash build.sh

popd

echo "All done!"
