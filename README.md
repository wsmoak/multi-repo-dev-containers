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

## Building the prebuilt image

The prebuilt image bakes in system packages, git clones, and dependency installs so
that new workspaces start quickly. Only the git pull, database setup, and migrations
run at container start time.

Rebuild periodically to keep the cloned repos close to HEAD.

```bash
# Set these for your environment
export AWS_ACCOUNT_ID=<your-account-id>
export AWS_REGION=us-east-2
export ECR_REPO=open-swe-devcontainer-prebuilds
export IMAGE_TAG=multi-repo-latest

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build
docker build -f .devcontainer/Dockerfile -t $ECR_REPO:$IMAGE_TAG .devcontainer/

# Tag and push
docker tag $ECR_REPO:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
```
