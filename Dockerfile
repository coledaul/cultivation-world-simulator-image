# syntax=docker/dockerfile:1

FROM node:22-alpine AS frontend-builder

WORKDIR /app

COPY web/package.json web/package-lock.json* ./
RUN npm ci

COPY web/ ./
COPY static/locales/registry.json /static/locales/registry.json
COPY static/game_configs/world_info.csv /static/game_configs/world_info.csv

RUN npm run build


FROM python:3.12-slim AS runtime

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements-runtime.txt ./

ARG PIP_INDEX_URL=https://pypi.org/simple
RUN pip install --no-cache-dir -r requirements-runtime.txt -i ${PIP_INDEX_URL}

COPY src/ ./src/
COPY static/ ./static/
COPY assets/ ./assets/
COPY --from=frontend-builder /app/dist ./web/dist

ENV PYTHONUNBUFFERED=1
ENV CWS_DATA_DIR=/data
ENV CWS_DISABLE_AUTO_SHUTDOWN=1
ENV CWS_NO_BROWSER=1

EXPOSE 8002

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8002/api/v1/query/runtime/status || exit 1

CMD ["uvicorn", "src.server.main:app", "--host", "0.0.0.0", "--port", "8002"]
