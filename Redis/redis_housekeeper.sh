#!/bin/bash
# Call this script for keeping backups for only 1 week
# Usage: sh house_keeper
#

find $1 -type f -mtime +7 -exec rm {} \;