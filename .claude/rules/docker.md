# Docker

- Multi-stage builds; keep final image minimal
- Pin base image versions (no `:latest`)
- One `RUN` per logical step; combine where it reduces layers
- COPY before RUN for cache efficiency
- Non-root USER in final stage
- `.dockerignore` alongside every Dockerfile
