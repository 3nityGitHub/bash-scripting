#!/bin/bash
set -e
set -u
LOG_DIRECTORY=$1
echo "Log directory requested: $LOG_DIRECTORY"
if [ -d "$LOG_DIRECTORY" ]; then
	echo "Log directory already exists.."
else
	echo "Creating log directory..."
	mkdir -p "$LOG_DIRECTORY"
fi

echo "Installing Node.js and npn ..."
sudo apt update
sudo apt install nodejs npm -y

echo "Node.js version: $(node --version) is installed"
echo "npm version: $(npm --version) is installed"

echo "Downloading app artifact..."
curl -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz

echo "Unzipping artifact..."
tar -xzf bootcamp-node-envvars-project-1.0.0.tgz

echo "Stage 1 complete: Node.js and npm installed and unpacked.."

echo "Setting environment variables..."
export APP_ENV=dev
export DB_USER=myuser
export DB_PWD=mysecret
export LOG_DIR=$(cd "$LOG_DIRECTORY" && pwd)
echo "LOG_DIR set to: $LOG_DIR"
echo "Entering app directory..."
cd package

echo "Installing app dependencies..."
npm install

echo "Starting the app in the background..."

node server.js &

echo "Stage 2 complete: app started."

echo "Waiting for the app to start..."
sleep 3

echo "Checking the app process:"
ps aux | grep "node server.js" | grep -v grep

echo "Checking the listening port:"
ss -tulpn | grep node
