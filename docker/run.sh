#!/bin/bash

set -euo pipefail

if [[ "$#" -lt 2 ]] ; then
  echo ""
  echo "Usage: run.sh <MODULE> <WEBAPP>"
  echo ""
  echo "MODULE: webapp.mod | webapp-hide-extension.mod"
  echo "WEBAPP: webapp-1 | webapp-2 | webapp-3"
  exit 1
fi

WEBAPP_MOD=$1
WEBAPP_NAME=$2
JETTY_PARAMS=${3:-}
SCRIPT_LOCATION=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
PROJECT_ROOT=$SCRIPT_LOCATION/../
DOCKER_ROOT=$PROJECT_ROOT/docker

echo ""
echo "Building simple-logback-extension..."
echo ""
$PROJECT_ROOT/gradlew -q -p $PROJECT_ROOT :simple-logback-extension:build

echo ""
echo "Building $WEBAPP_NAME..."
echo ""
$PROJECT_ROOT/gradlew -q -p $PROJECT_ROOT :$WEBAPP_NAME:build

echo ""
echo "Building docker image..."
echo ""
cp $PROJECT_ROOT/simple-logback-extension/build/libs/simple-logback-extension.jar $DOCKER_ROOT/files/
cp $PROJECT_ROOT/$WEBAPP_NAME/build/libs/$WEBAPP_NAME.war $DOCKER_ROOT/files/webapp.war
cp $DOCKER_ROOT/$WEBAPP_MOD $DOCKER_ROOT/files/webapp.mod
docker build -q -f $DOCKER_ROOT/Dockerfile -t webapp:latest $DOCKER_ROOT/files

echo ""
echo "Running $WEBAPP_NAME..."
echo ""
docker run -it --rm --name $WEBAPP_NAME -p 8080:8080 -p 9999:9999 webapp:latest $JETTY_PARAMS
