AGENT_VERSION=2.172.0
AGENT_ARCHIVE=vsts-agent-linux-x64-$AGENT_VERSION.tar.gz

mkdir -p agent
cd agent
wget -O $AGENT_ARCHIVE https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/$AGENT_ARCHIVE
tar xvfz $AGENT_ARCHIVE
./config.sh --unattended --url ${ORG}  --auth pat --token ${PAT} --pool default --agent ${NAME}  --acceptTeeEula
sudo ./svc.sh install
sudo ./svc.sh start
