#!/bin/bash
set -e
set -u

echo "Showing user processes for $USER "
read -p "Sort by memory or by cpu? " USER_CHOICE
read -p "How many process-count do you want to show? " COUNT

if [ "$USER_CHOICE" = "memory" ]; then
	ps aux | grep "$USER" | grep -v grep | sort -k4 -rn | head -n "$COUNT"

elif [ "$USER_CHOICE" = "cpu" ]; then
	ps aux | grep "$USER" | grep -v grep | sort -k3 -rn | head -n "$COUNT"

else
	echo "Invalid choice, Please enter 'memory'or 'cpu'"

fi

