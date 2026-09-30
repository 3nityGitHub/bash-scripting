#!/bin/bash
set -e
set -u

echo "Showing user processes for $USER "
read -p "Sort by memory or by cpu? " USER_CHOICE

if [ "$USER_CHOICE" = "memory" ]; then
	ps aux | grep "$USER" | grep -v grep | sort -k3 -rn

elif [ "$USER_CHOICE" = "cpu" ]; then
	ps aux | grep "$USER" | grep -v grep | sort -k4 -rn

else
	echo "Invalid choice, Please enter 'memory'or 'cpu'"

fi

