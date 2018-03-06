FROM hootsuite/atlantis

# Update & Required for the wgets
RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl
RUN apk upgrade

# Args
ARG TF_VERSION=0.11.3

# Configure symlinks
# AWS
RUN ln -s /home/atlantis/mounts/.aws/credentials /home/atlantis/.aws/credentials

## Configure Global vars
# Custom AMIs I want to reference globally.
ENV TF_VAR_AMI_AWSLINUX_V1-0-1 ami-123456
ENV TF_VAR_AMI_CENTLINUX_V7-0-1 ami-246810


## Update Terraform and add back versions
# Back versions are normaly the highest release for the major version.  See https://releases.hashicorp.com/terraform/
RUN mkdir -p mkdir /usr/local/bin/tf/versions/${TF_VERSION}
RUN wget --directory-prefix=/usr/local/bin/tf/versions/${TF_VERSION}/ https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN unzip /usr/local/bin/tf/versions/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN rm -f /usr/local/bin/tf/versions/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
RUN ln -s -f /usr/local/bin/tf/versions/${TF_VERSION}/terraform /usr/local/bin/terraform${TF_VERSION}
RUN rm -f /usr/local/bin/terraform
RUN ln -s -f /usr/local/bin/tf/versions/${TF_VERSION}/terraform /usr/local/bin/terraform

# 0.10.8
RUN mkdir -p mkdir /usr/local/bin/tf/versions/0.10.8
RUN wget --directory-prefix=/usr/local/bin/tf/versions/0.10.8/ https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip
RUN unzip /usr/local/bin/tf/versions/0.10.8/terraform_0.10.8_linux_amd64.zip
RUN rm -f /usr/local/bin/tf/versions/0.10.8/terraform_0.10.8_linux_amd64.zip
RUN ln -s -f /usr/local/bin/tf/versions/0.10.8/terraform /usr/local/bin/terraform0.10.8

# 0.9.11
RUN mkdir -p mkdir /usr/local/bin/tf/versions/0.9.11
RUN wget --directory-prefix=/usr/local/bin/tf/versions/0.9.11/ https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip
RUN unzip /usr/local/bin/tf/versions/0.9.11/terraform_0.9.11_linux_amd64.zip
RUN rm -f /usr/local/bin/tf/versions/0.9.11/terraform_0.9.11_linux_amd64.zip
RUN ln -s -f /usr/local/bin/tf/versions/0.9.11/terraform /usr/local/bin/terraform0.9.11
