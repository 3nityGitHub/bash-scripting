#!/bin/bash
set -e
set -u

echo "Installing Java..."
sudo apt update
sudo apt install openjdk-17-jdk -y

JAVA_OUTPUT=$(java -version 2>&1)

if ! command -v java &> /dev/null; then
	echo "Java is not installed"
else
    JAVA_VERSION=$(echo "$JAVA_OUTPUT" | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
    if [ "$JAVA_VERSION" -ge 11 ]; then
        echo "Java is installed and up to date (version $JAVA_VERSION)"
    else
        echo "An older Java version ($JAVA_VERSION) is installed, please upgrade to 11 or higher"
    fi
fi
