FROM ubuntu:18.04

USER root

RUN  apt-get update

COPY bbb-install.sh /tmp/bbb-install.sh
RUN  chmod +x /tmp/bbb-install.sh
RUN  /tmp/bbb-install.sh -s -- -w -a -v bionic-23 -s $GITPOD_WORKSPACE_URL -e admin@example.com

USER gitpod
