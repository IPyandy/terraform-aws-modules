#!/usr/bin/bash

sudo yum update -y
sudo yum install python3 python3-tools -y
sudo yum install git -y
sudo yum install zsh -y
sudo yum install bash-completion -y
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin/
sudo chmod +x /usr/local/bin/kubectl
curl -o heptio-authenticator-aws https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws
chmod +x heptio-authenticator-aws
sudo mv heptio-authenticator-aws /usr/local/bin/heptio-authenticator-aws
mkdir -pv $HOME/.kube
git clone https://github.com/IPyandy/dotfiles-linux.git $HOME/dotfiles
source $HOME/dotfiles/bootstrap.sh
