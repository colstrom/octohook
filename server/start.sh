#!/usr/bin/env bash
set -e            # Exit of errors      
PWD=$(dirname $0) # Get the path of ./start.sh
cd $PWD           # Jump into the path of ./start.sh

: ${GITHUB_SECRET?"Need to set GITHUB_SECRET"}
: ${JENKINS_SECRET?"Need to set JENKINS_SECRET"}

IMAGE_NAME=$(./build.sh) # Get the name of the image

if [ "$IMAGE_NAME" != "" ]; then
        docker run -P -d $IMAGE_NAME
fi

