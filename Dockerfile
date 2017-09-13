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
  sudo && yum clean all

RUN pip3 install awscli

WORKDIR /usr/local/bin
# Install required binaries: dcos, dcos-launch and kubectl
ENV DCOS_LAUNCH_VERSION 0.5.5
RUN curl -o dcos https://downloads.dcos.io/binaries/cli/linux/x86-64/$DCOS_LAUNCH_VERSION/dcos \
    && chmod +x dcos

RUN curl -o dcos-launch https://downloads.dcos.io/dcos-launch/bin/linux/dcos-launch \
    && chmod +x dcos-launch

ENV KUBERNETES_VERSION v1.7.5
ENV KUBERNETES_DOWNLOAD_URL https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl
ENV KUBERNETES_DOWNLOAD_SHA256 0392ed74bc29137b2a7db7aca9a0a0c1bc85c4cd55b6a42ea556e1a7c485f745
RUN curl -fsSL "$KUBERNETES_DOWNLOAD_URL" -o kubectl \
  && echo "$KUBERNETES_DOWNLOAD_SHA256  kubectl" | sha256sum -c - \
  && chmod +x kubectl

RUN mkdir /dcos-kubernetes
WORKDIR /dcos-kubernetes
