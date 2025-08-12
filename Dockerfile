FROM alpine:latest

USER root
RUN addgroup terraform
RUN adduser -G terraform -h /home/terraform -D terraform

RUN apk add curl unzip
RUN mkdir -p /opt/terraform

ARG TERRAFORM_VERSION=1.12.2
RUN apk update && \
    curl -LOs https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /opt/terraform \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV PATH=/opt/terraform:${PATH}

RUN mkdir -p /opt/terraform/plugins
ADD filesystem-mirror-example.tfrc /opt/terraform/config.tfrc

RUN mkdir -p /opt/terraform/plugins/registry.terraform.io
WORKDIR /opt/terraform/plugins/registry.terraform.io
ARG OPENSTACK_PROVIDER_VERSION=1.54.1
RUN echo "Adding terraform-provider-openstack/openstack v${OPENSTACK_PROVIDER_VERSION}" \
    && mkdir -p terraform-provider-openstack/openstack && cd terraform-provider-openstack/openstack \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-openstack/${OPENSTACK_PROVIDER_VERSION}/terraform-provider-openstack_${OPENSTACK_PROVIDER_VERSION}_linux_amd64.zip
ARG CLOUDINIT_PROVIDER_VERSION=2.3.7
RUN echo "Adding hashicorp/cloudinit v${CLOUDINIT_PROVIDER_VERSION}" \
    && mkdir -p hashicorp/cloudinit && cd hashicorp/cloudinit \
    && curl -LOs https://github.com/hashicorp/terraform-provider-cloudinit/archive/refs/tags/v${CLOUDINIT_PROVIDER_VERSION}.zip
ARG NULL_PROVIDER_VERSION=2.3.7
RUN echo "Adding hashicorp/null v${NULL_PROVIDER_VERSION}" \
    && mkdir -p hashicorp/null && cd hashicorp/null \
    && curl -LOs https://github.com/hashicorp/terraform-provider-null/archive/refs/tags/v${NULL_PROVIDER_VERSION}.zip
RUN chown -R terraform:terraform /opt/terraform/plugins
WORKDIR /home/terraform

USER terraform

# Use the tfrc file to inform
ENV TF_CLI_CONFIG_FILE=/opt/terraform/config.tfrc
