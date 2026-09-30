#!/bin/bash
set -e
set -u

echo "Showing user processes for $USER "

USER_PROCESS=$(ps aux | grep "$USER" | grep -v grep)

echo "$USER_PROCESS"
