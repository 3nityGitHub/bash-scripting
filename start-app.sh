#!/bin/bash
set -e
set -u

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
