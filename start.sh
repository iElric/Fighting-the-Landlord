#!/bin/bash

export MIX_ENV=prod
export PORT=4793

echo "Starting app..."

# Start to run in background from shell.
#_build/prod/rel/memory/bin/memory start

# Foreground for testing and for systemd
_build/prod/rel/fighting_the_landlord/bin/fighting_the_landlord start

# TODO: Add a systemd service file
#       to start your app on system boot.

