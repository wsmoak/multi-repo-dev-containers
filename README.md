# Multi-Repo Dev Containers

Multi-repo devcontainer setup for OpenSWE + DevPod.

Clones and configures these projects in a single workspace:
- [rails-otel-demo](https://github.com/wsmoak/rails-otel-demo) - Rails with OpenTelemetry
- [django-polls-playwright-demo](https://github.com/wsmoak/django-polls-playwright-demo) - Django with Playwright tests

## Usage with DevPod

```bash
devpod up --source git:https://github.com/wsmoak/multi-repo-dev-containers --provider aws
```

## What it sets up

- Python 3.12 base image, Ruby and Node.js via apt
- PostgreSQL via apt (trust auth on localhost)
- Clones both repos into `/workspaces/`
- Runs Django migrations and Rails bundle install
- `postStartCommand` restarts Postgres on container start (for prebuilt images)
