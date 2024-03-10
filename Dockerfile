FROM ubuntu:22.04
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000
ENV WORKDIR=/dev-env

LABEL "maintainer"="Daddy Knows Best"
LABEL org.opencontainers.image.source=https://github.com/daddy-knows-best/dev-env
LABEL org.opencontainers.image.description="Daddy's dev env"

RUN groupadd --gid $USER_GID $USERNAME && \
	useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME

ENV TZ America/Central

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex && \
  apt update && \
  apt install -y \
    sudo \
    vim \
    git \
    curl \
    build-essential \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    llvm \
    make \
    tk-dev \
    wget \
    xz-utils \
    zlib1g-dev \
    apt-transport-https \
    jq \
    unzip \
    iputils-ping \
    dnsutils \
    traceroute \
    iproute2 \
    netcat \
    psmisc \
  && \
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
	chmod 0440 /etc/sudoers.d/$USERNAME

# set environmental variables
USER $USERNAME
ENV HOME "/home/${USERNAME}"
ENV LC_ALL "C.UTF-8"
ENV LANG "en_US.UTF-8"

# pyenv
ENV PYENV_ROOT "${HOME}/.pyenv"
ENV PATH "${HOME}/.pyenv/shims:${HOME}/.pyenv/bin:${PATH}"
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
#
RUN set -ex && \
  curl https://pyenv.run | bash && \
  pyenv install 3.10.6 && \
  pyenv global 3.10.6 && \
  pip install --upgrade pip

RUN set -ex && \
  # Ansible, pipenv, pre-commit, detect-secrets
  pip install \
  ansible \
  pipenv \
  pre-commit \
  detect-secrets

# ohmybash
RUN set -ex && \
  cd ${HOME} && \
  cp .bashrc .bashrc_copy && \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" && \
  cat .bashrc_copy >> .bashrc && \
  rm .bashrc_copy

# kubectl cli
RUN set -ex && \
  bash -c "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg" && \
  bash -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list" && \
  sudo apt update && \
  sudo apt install -y kubectl && \
  echo 'alias k=kubectl' >> ~/.bashrc

#COPY ~/.kube/ ${HOME}/.kube

# docker and docker-compose
RUN set -ex && \
  bash -c "for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove $pkg; done" && \
  # Add Docker's official GPG key:
  bash -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg" && \
  sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
  bash -c 'echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null' && \
  sudo apt update  && \
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ubuntu 22.04 ssh rsa does not work for pakcer-provisioner-ansible; let's add temporary workaround
RUN set -ex && \
  echo '    PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config && \
  echo '    HostKeyAlgorithms +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config && \
  sudo usermod -aG docker ${USERNAME} && \
  sudo usermod -aG root ${USERNAME}

# hci
RUN set -ex && \
  cd ${HOME} && \
  curl iac.sh/hci > hci && \
  chmod +x hci && \
  sudo mv hci /usr/local/bin

# golang 1.22.1
RUN set -ex && \
  cd ${HOME} && \
  wget -q https://go.dev/dl/go1.22.1.linux-amd64.tar.gz && \
  sudo rm -rf /usr/local/go && \
  sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz && \
  rm -rf ${HOME}/*.gz && \
  echo "PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc

ENV PATH "${PATH}:/usr/local/go/bin"

#RUN rm -rf /var/lib/apt/lists/*
#RUN apt clean

WORKDIR ${WORKDIR}
