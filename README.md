# taskchampion-sync-server wrapper

A thin wrapper around the [official taskchampion-sync-server image](https://github.com/GothenburgBitFactory/taskchampion-sync-server) that adds `PUID`/`PGID` support for correct file ownership on the host.

## Image

```
ghcr.io/furan917/taskchampion-sync-server:latest
```

> **A `CLIENT_ID` must be provided or the container will not start.** This is a hard requirement due to the upstream taskchampion-sync-server having no HTTP authentication — without a UUID allowlist, any client that can reach the server URL can sync against it. Once all your devices have synced for the first time, ensure you set `NO_CREATE_CLIENTS=true` to prevent any new clients from registering against your server.

## Environment variables

| Variable            | Default    | Required | Description                                                                 |
|---------------------|------------|----------|-----------------------------------------------------------------------------|
| `CLIENT_ID`         | —          | **Yes**  | UUID(s) of clients allowed to sync. Comma-separated for multiple devices. The container will not start without this. |
| `PUID`              | `1000`     | No       | UID the server process runs as                                              |
| `PGID`              | `1000`     | No       | GID the server process runs as                                              |
| `LISTEN`            | `0.0.0.0:8080` | No   | Address and port to listen on                                               |
| `DATA_DIR`          | `/var/lib/taskchampion-sync-server` | No | Path to store the SQLite database         |
| `NO_CREATE_CLIENTS` | `false`    | No       | Set to `true` to block new client registration. Only enable after all your devices have synced at least once — enabling before first sync will block even allowed clients. |

## Security

**The upstream taskchampion-sync-server provides no HTTP authentication.** This is a limitation of the upstream project, not this wrapper. Access control is via `CLIENT_ID` UUID allowlisting only. UUIDs are 128-bit random values and effectively unguessable, and task data is encrypted client-side so the server never holds plaintext.

`CLIENT_ID` is required — the container will refuse to start without it, ensuring the server is never accidentally left open.

For LAN-only deployments this is sufficient. **If you expose this to the internet, place it behind a reverse proxy (e.g. Nginx Proxy Manager) with HTTP Basic Auth** so that a leaked UUID alone is not enough to connect.

## Client configuration (Taskwarrior)

Generate a UUID for each device (`uuidgen` on Linux/Mac), add them all to `CLIENT_ID` on the server, then configure each client:

```sh
task config sync.server.url http://<host>:8007/
task config sync.server.client_id <uuid>        # the UUID you added to CLIENT_ID
task config sync.encryption_secret <passphrase> # same passphrase on all devices
task sync
```

## Updates

Upstream image updates are tracked automatically via Renovate. A PR is opened when a new image tag appears on GHCR — merge it to release a new wrapper image.
