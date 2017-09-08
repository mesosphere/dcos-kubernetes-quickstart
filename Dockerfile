FROM ubuntu:16.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  jq \
  make \
  build-essential \
  libssl-dev \
  libffi-dev \
  python-dev \
  python3-pip \
  python3-venv \
  python3-setuptools \
  openssh-client \
  git \
  locales \
  rsync \
  sudo && apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN pip3 install awscli

RUN git clone https://github.com/dcos/dcos-launch.git && \
    cd dcos-launch && \
    git checkout 61389f393f136908f429cfe8ebccbd5e2412da47
WORKDIR dcos-launch
RUN pip3 install -r requirements.txt
RUN python3 setup.py develop

WORKDIR /usr/local/bin
RUN curl -o dcos https://downloads.dcos.io/binaries/cli/linux/x86-64/0.5.5/dcos
RUN chmod +x dcos

ENV KUBERNETES_VERSION v1.7.5
ENV KUBERNETES_DOWNLOAD_URL https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl
ENV KUBERNETES_DOWNLOAD_SHA256 0392ed74bc29137b2a7db7aca9a0a0c1bc85c4cd55b6a42ea556e1a7c485f745
RUN curl -fsSL "$KUBERNETES_DOWNLOAD_URL" -o kubectl \
  && echo "$KUBERNETES_DOWNLOAD_SHA256  kubectl" | sha256sum -c - \
  && chmod +x kubectl

RUN mkdir /dcos-kubernetes
WORKDIR /dcos-kubernetes
