nvm install node
npm install -g yarn 

sudo apt-get install jq -y 

wget https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz

echo "export PATH=\"$PATH:/usr/local/go/bin\"" >> ~/.bashrc
echo "export GOPATH=/home/$USER/go" >> ~/.bashrc

HOSTS=`cat <<EOF
127.0.0.1 dex
127.0.0.1 minio
127.0.0.1 postgres
127.0.0.1 mysql
EOF
`

sudo -- sh -c "echo \"$HOSTS\" >> /etc/hosts" 

mkdir /home/$USER/go
mkdir /home/$USER/go/src
mkdir /home/$USER/go/src/github.com
mkdir /home/$USER/go/src/github.com/argoproj

cd /home/$USER/go/src/github.com/argoproj
git clone https://github.com/argoproj/argo-workflows.git 

