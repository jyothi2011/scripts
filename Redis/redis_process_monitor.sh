#!/bin/bash

# Check if gedit is running
if ps aux | grep "[6]379" > /dev/null
then
    echo "Running"
else
    echo "Stopped"
fi