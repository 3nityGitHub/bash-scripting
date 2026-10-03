#!/bin/bash
set -e
set -u
LOG_DIRECTORY=$1
echo "Log directory requested: $LOG_DIRECTORY"
if [ -d "$LOG_DIRECTORY" ]; then
	echo "Log directory already exists.."
else
	echo "Creating log directory..."
	sudo mkdir -p "$LOG_DIRECTORY"
fi
if id myapp &>/dev/null; then
    echo "Service user myapp already exists"
else
    echo "Creating service user myapp..."
    sudo useradd -m myapp
fi

echo "Installing Node.js and npn ..."
sudo apt update
sudo apt install nodejs npm -y

echo "Node.js version: $(node --version) is installed"
echo "npm version: $(npm --version) is installed"

echo "Downloading app artifact..."
curl -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz


echo "Setting up app directory in /opt..."
sudo rm -rf /opt/myapp
sudo mkdir -p /opt/myapp
sudo tar -xzf bootcamp-node-envvars-project-1.0.0.tgz -C /opt/myapp --strip-components=1

echo "Stage 1 complete: installed and unpacked into /opt/myapp"

echo "Setting environment variables..."
export APP_ENV=dev
export DB_USER=myuser
export DB_PWD=mysecret
export LOG_DIR=$(cd "$LOG_DIRECTORY" && pwd)
echo "LOG_DIR set to: $LOG_DIR"

echo "Giving myapp ownership of app files and logs..."
sudo chown -R myapp:myapp /opt/myapp
sudo chown -R myapp:myapp "$LOG_DIR"

echo "Installing app dependencies as myapp..."
cd /opt/myapp
sudo -u myapp npm install

echo "Starting the app as myapp in the background..."
sudo -u myapp bash -c "cd /opt/myapp && \
  APP_ENV='$APP_ENV' \
  DB_USER='$DB_USER' \
  DB_PWD='$DB_PWD' \
  LOG_DIR='$LOG_DIR' \
  node server.js" &



echo "Stage 2 complete: app started."

echo "Waiting for the app to start..."
sleep 3

echo "Checking the app process:"
ps aux | grep "node server.js" | grep -v grep

echo "Checking the listening port:"
ss -tulpn | grep node
