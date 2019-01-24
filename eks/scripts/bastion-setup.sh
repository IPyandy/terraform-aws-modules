#!/usr/bin/bash

sudo yum update -y
sudo yum install python3 python3-tools -y
sudo yum install git -y
sudo yum install zsh -y
sudo yum install bash-completion -y
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
sudo ln -sf /usr/local/bin/aws-iam-authenticator /usr/local/bin/heptio-authenticator-aws
mkdir -pv $HOME/.kube
git clone https://github.com/IPyandy/dotfiles-linux.git $HOME/dotfiles
source $HOME/dotfiles/bootstrap.sh
