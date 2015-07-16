#!/usr/bin/env bash

cp support/deploy.rsa /home/stackato/.ssh/id_rsa
chmod 0400 /home/stackato/.ssh/id_rsa
ssh-keyscan github.com >> /home/stackato/.ssh/known_hosts

REPO="${STACKATO_FILESYSTEM}/stackato-release-st"

if [ -d ${REPO} ]; then
  pushd ${REPO}
  git pull
  popd
fi
