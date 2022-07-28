FROM debian:stable-slim

ENV TERRAFORM_VERSION 0.12.18
ENV ANSIBLE_VERSION 2.9.4

RUN apt-get -y update && \
    apt-get -y install \
    openssh-client \
    python \
    python-pip \
    unzip \
    vim \
    && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/*

WORKDIR /p88

COPY . .

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/

RUN unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN pip install ansible==${ANSIBLE_VERSION}
