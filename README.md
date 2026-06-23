# cultivation-world-simulator image builder

Personal GitHub Actions builder for a single-container image of
[4thfever/cultivation-world-simulator](https://github.com/4thfever/cultivation-world-simulator).

The workflow checks out the upstream project, builds the web frontend into
`web/dist`, copies it into the Python runtime image, and publishes:

```text
ghcr.io/coledaul/cultivation-world-simulator:latest
```

## Run

```bash
docker run -d \
  --name cws \
  -p 8123:8002 \
  -v "$PWD/docker-data:/data" \
  -e CWS_DATA_DIR=/data \
  -e CWS_DISABLE_AUTO_SHUTDOWN=1 \
  -e CWS_NO_BROWSER=1 \
  --restart unless-stopped \
  ghcr.io/coledaul/cultivation-world-simulator:latest
```

Open:

```text
http://localhost:8123
```

## Docker Compose

```yaml
services:
  cws:
    image: ghcr.io/coledaul/cultivation-world-simulator:latest
    container_name: cultivation-world-simulator
    ports:
      - "8123:8002"
    environment:
      - CWS_DATA_DIR=/data
      - CWS_DISABLE_AUTO_SHUTDOWN=1
      - CWS_NO_BROWSER=1
      - PYTHONUNBUFFERED=1
    volumes:
      - ./docker-data:/data
    restart: unless-stopped
```

Update:

```bash
docker compose pull
docker compose up -d
```
