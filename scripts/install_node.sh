nvm install node
npm install -g yarn 

sudo apt-get install jq -y 

wget https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz

echo "export PATH=\"$PATH:/usr/local/go/bin\"" >> ~/.bashrc
