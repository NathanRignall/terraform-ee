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
ARG OPENSTACK_PROVIDER_VERSION=3.3.2
RUN echo "Adding openstack/openstack v${OPENSTACK_PROVIDER_VERSION}" \
    && mkdir -p openstack/openstack && cd openstack/openstack \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-openstack/${OPENSTACK_PROVIDER_VERSION}/terraform-provider-openstack_${OPENSTACK_PROVIDER_VERSION}_linux_amd64.zip
    
RUN chown -R terraform:terraform /opt/terraform/plugins
WORKDIR /home/terraform

USER terraform

# Use the tfrc file to inform
ENV TF_CLI_CONFIG_FILE=/opt/terraform/config.tfrc
