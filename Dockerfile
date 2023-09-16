FROM ubuntu:22.04
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

LABEL "maintainer"="Daddy Knows Best"
LABEL org.opencontainers.image.source=https://github.com/daddy-knows-best/dev-env
LABEL org.opencontainers.image.description="Dadd's dev env"

RUN groupadd --gid $USER_GID $USERNAME && \
	useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME


ENV WORKDIR=/dev-env
ENV TZ America/Central

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN set -ex && \
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
  && \
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
	chmod 0440 /etc/sudoers.d/$USERNAME

# set environmental variables
USER $USERNAME
ENV HOME "/home/${USERNAME}"
ENV LC_ALL "C.UTF-8"
ENV LANG "en_US.UTF-8"

#RUN rm -rf /var/lib/apt/lists/*
#RUN apt clean

# pyenv
ENV PYENV_ROOT "${HOME}/.pyenv"
ENV PATH "${HOME}/.pyenv/shims:${HOME}/.pyenv/bin:${PATH}"
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
#
RUN set -ex && \
	curl https://pyenv.run | bash && \
	pyenv install 3.11 && \
	pyenv global 3.11 && \
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

WORKDIR ${WORKDIR}
