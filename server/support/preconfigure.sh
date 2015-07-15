#!/usr/bin/env sh

cp support/deploy.rsa /home/stackato/.ssh/id_rsa
chmod 0400 /home/stackato/.ssh/id_rsa
ssh-keyscan github.com >> /home/stackato/.ssh/known_hosts
