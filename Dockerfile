FROM debian:stable-slim

ARG USERNAME=devops
ARG USER_UID=1000
ARG USER_GID=$USER_UID

LABEL version="0.0.1"
LABEL repository="https://github.com/rafaelbmateus/p88"
LABEL description="Provisionamento de infraestrutura como código usando Ansible e Terraform no DigitalOcean."

ENV TERRAFORM_VERSION 0.12.18
ENV ANSIBLE_VERSION 2.9.4

RUN apt-get -y update && \
    apt-get -y install \
    openssh-client \
    python \
    python3-pip \
    unzip \
    vim \
    && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/*

WORKDIR /p88

# Add non-root user
RUN groupadd --gid $USER_GID $USERNAME
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
RUN chown -R $USERNAME /p88

COPY --chown=$USERNAME . .

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/

RUN unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN pip install ansible==${ANSIBLE_VERSION}

USER $USERNAME