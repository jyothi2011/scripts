#!/bin/bash
# Keeping logs for only 30 days
# Usage: ./redis_log_housekeeper

find /var/redis/6379/*.old -type f -mtime +30 -delete