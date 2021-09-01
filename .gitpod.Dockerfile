FROM ubuntu:18.04

USER root

ARG DEBIAN_FRONTEND=noninteractive
ENV RUNLEVEL=1

RUN apt-get clean -y

RUN rm -rf \
   /var/cache/debconf/* \
   /var/lib/apt/lists/* \
   /tmp/* \
   /var/tmp/*

RUN apt-get update

RUN apt-get install -yq --no-install-recommends util-linux mount bsdutils bash ssl-cert zip unzip build-essential ninja-build htop jq less locales man-db nano software-properties-common sudo time emacs-nox vim multitail lsof fish zsh git wget git-completion curl ssh \
  && locale-gen en_US.UTF-8

### Git ###
RUN add-apt-repository -y ppa:git-core/ppa \
    && apt-get install -y git git-lfs


### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

ENV HOME=/home/gitpod

WORKDIR $HOME
# custom Bash prompt
RUN { echo && echo "PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]$ '" ; } >> .bashrc

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success" && \
    # create .bashrc.d folder and source it in the bashrc
    mkdir /home/gitpod/.bashrc.d && \
    (echo; echo "for i in \$(ls \$HOME/.bashrc.d/*); do source \$i; done"; echo) >> /home/gitpod/.bashrc

# configure git-lfs
RUN sudo git lfs install --system

### Node.js ###
# ENV NODE_VERSION=12.22.5
# RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | PROFILE=/dev/null bash \
#     && bash -c ". .nvm/nvm.sh \
#         && nvm install $NODE_VERSION \
#         && nvm alias default $NODE_VERSION \
#         && npm install -g typescript yarn node-gyp" \
#     && echo ". ~/.nvm/nvm.sh"  >> /home/gitpod/.bashrc.d/50-node
# above, we are adding the nvm init to .bashrc, because one is executed on interactive shells, the other for non-interactive shells (e.g. plugin-host)
# RUN sudo chown gitpod:gitpod ~/.nvm/nvm.sh
# ENV PATH=$PATH:/home/gitpod/.nvm/versions/node/v${NODE_VERSION}/bin

### Install NodeJS 12 using nodesource (required by bbb) ###
CMD sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 37B5DD5EFAB46452
RUN sudo apt -y install dirmngr apt-transport-https lsb-release ca-certificates \
  && curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
  && sudo apt-get install -y nodejs
