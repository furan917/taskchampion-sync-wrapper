# taskchampion-sync-server wrapper

A thin wrapper around the [official taskchampion-sync-server image](https://github.com/GothenburgBitFactory/taskchampion-sync-server) that adds `PUID`/`PGID` support for correct file ownership on the host.

## Image

```
ghcr.io/furan917/taskchampion-sync-server:latest
```

## Environment variables

| Variable            | Default    | Description                                                                 |
|---------------------|------------|-----------------------------------------------------------------------------|
| `PUID`              | `1000`     | UID the server process runs as                                              |
| `PGID`              | `1000`     | GID the server process runs as                                              |
| `LISTEN`            | `0.0.0.0:8080` | Address and port to listen on                                           |
| `DATA_DIR`          | `/var/lib/taskchampion-sync-server` | Path to store the SQLite database              |
| `CLIENT_ID`         | _(empty)_  | Comma-separated UUID(s) allowed to sync. If unset, all clients are allowed |
| `NO_CREATE_CLIENTS` | `false`    | Set to `true` to lock the DB after all devices have synced once. Enabling before first sync will block even allowed clients. |

## Security

**The upstream taskchampion-sync-server provides no HTTP authentication.** This is a limitation of the upstream project, not this wrapper. Access control is via `CLIENT_ID` UUID allowlisting only. UUIDs are 128-bit random values and effectively unguessable, and task data is encrypted client-side so the server never holds plaintext.

For LAN-only deployments this is sufficient. **If you expose this to the internet, place it behind a reverse proxy (e.g. Nginx Proxy Manager) with HTTP Basic Auth** so that a leaked UUID alone is not enough to connect.

## Client configuration (Taskwarrior)

```sh
task config sync.server.url http://<host>:8080/
task config sync.server.client_id $(uuidgen)   # unique per device
task config sync.server.encryption_secret <passphrase>
```

## Updates

Upstream image updates are tracked automatically via Renovate. A PR is opened when a new image tag appears on GHCR — merge it to release a new wrapper image.
