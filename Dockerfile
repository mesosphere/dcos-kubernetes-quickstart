FROM centos:7

RUN yum update -y && yum install -y epel-release && yum install -y \
  python34-pip \
  curl \
  jq \
  make \
  kernel-devel \
  kernel-headers \
  openssl-devel \
  libffi-devel \
  openssh-clients \
  git \
  rsync \
  which \
  sudo && yum clean all

RUN pip3 install awscli typing

WORKDIR /usr/local/bin
# Install required binaries: dcos, dcos-launch and kubectl
ENV DCOS_LAUNCH_VERSION 0.5.6
RUN curl -o dcos https://downloads.dcos.io/binaries/cli/linux/x86-64/$DCOS_LAUNCH_VERSION/dcos \
    && chmod +x dcos

RUN git clone https://github.com/dcos/dcos-launch.git && \
    cd dcos-launch && \
    git checkout 261ab82af4fd0a4daa207c7c2328d8eebcdd57b7 && \
    pip3 install -r requirements.txt && \
    python3 setup.py develop

ENV KUBERNETES_VERSION v1.9.0
ENV KUBERNETES_DOWNLOAD_URL https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl
RUN curl -fsSL "$KUBERNETES_DOWNLOAD_URL" -o kubectl \
  && chmod +x kubectl

RUN mkdir /dcos-kubernetes
WORKDIR /dcos-kubernetes
