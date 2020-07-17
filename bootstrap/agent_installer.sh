AGENT_VERSION=2.172.0
AGENT_ARCHIVE=vsts-agent-linux-x64-$AGENT_VERSION.tar.gz

# Install build agent

mkdir -p agent
cd agent
wget -O $AGENT_ARCHIVE https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/$AGENT_ARCHIVE
tar xvfz $AGENT_ARCHIVE
./bin/installdependencies.sh
AGENT_ALLOW_RUNASROOT="1" ./config.sh --unattended --url ${ORG}  --auth pat --token ${PAT} --pool default --agent ${NAME}  --acceptTeeEula
./svc.sh install
./svc.sh start

# Install Docker

apt-get update
apt-get -y autoremove docker docker-engine docker.io containerd runc
apt-get -y install 
apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io

# Install Azure CLI

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install build-essential

apt-get -y install build-essential
