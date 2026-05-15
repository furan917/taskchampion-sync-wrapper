#!/bin/sh
set -e

PUID=${PUID:-1000}
PGID=${PGID:-1000}
DATA_DIR=${DATA_DIR:-/var/lib/taskchampion-sync-server}
LISTEN=${LISTEN:-0.0.0.0:8080}

mkdir -p "$DATA_DIR"
chown -R "$PUID:$PGID" "$DATA_DIR"
chmod -R 700 "$DATA_DIR"

if [ -z "$CLIENT_ID" ]; then
    echo "ERROR: CLIENT_ID is required. Generate a UUID with 'uuidgen' and set it in the container configuration."
    exit 1
fi

set -- --listen "$LISTEN" --data-dir "$DATA_DIR"

# CLIENT_ID accepts a single UUID or a comma-separated list for multiple devices
if [ -n "$CLIENT_ID" ]; then
    OLD_IFS="$IFS"
    IFS=','
    for id in $CLIENT_ID; do
        id=$(echo "$id" | tr -d ' ')
        [ -n "$id" ] && set -- "$@" --allow-client-id "$id"
    done
    IFS="$OLD_IFS"
fi

if [ "$NO_CREATE_CLIENTS" = "true" ]; then
    set -- "$@" --no-create-clients
fi

# Unset env vars the binary reads directly so our processed flags take precedence
unset CLIENT_ID
unset NO_CREATE_CLIENTS

exec su-exec "$PUID:$PGID" /bin/taskchampion-sync-server "$@"
