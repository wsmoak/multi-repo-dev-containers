#!/bin/bash
set -e

echo "=== OpenSWE Multi-Repo Post-Create ==="

# Clone repos into /workspaces (DevPod manages this dir as a volume,
# so repos baked into the Docker image at /workspaces/ are not available)
WORKSPACES="/workspaces"

if [ ! -d "$WORKSPACES/rails-otel-demo/.git" ]; then
  echo "Cloning rails-otel-demo..."
  rm -rf "$WORKSPACES/rails-otel-demo"
  git clone https://github.com/wsmoak/rails-otel-demo "$WORKSPACES/rails-otel-demo"
else
  echo "Pulling latest rails-otel-demo..."
  git -C "$WORKSPACES/rails-otel-demo" pull --ff-only || true
fi

if [ ! -d "$WORKSPACES/django-polls-playwright-demo/.git" ]; then
  echo "Cloning django-polls-playwright-demo..."
  rm -rf "$WORKSPACES/django-polls-playwright-demo"
  git clone https://github.com/wsmoak/django-polls-playwright-demo "$WORKSPACES/django-polls-playwright-demo"
else
  echo "Pulling latest django-polls-playwright-demo..."
  git -C "$WORKSPACES/django-polls-playwright-demo" pull --ff-only || true
fi

# Start PostgreSQL
echo "Starting PostgreSQL..."
sudo service postgresql start

echo "Waiting for PostgreSQL..."
for i in {1..30}; do
  if pg_isready -h 127.0.0.1 -p 5432 > /dev/null 2>&1; then
    echo "PostgreSQL is ready"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "PostgreSQL not ready after 30s"
    exit 1
  fi
  sleep 1
done

# Create Django database users and databases
echo "Setting up Django database..."
psql -U postgres -h 127.0.0.1 -c "CREATE USER demo_app_user WITH PASSWORD 'supersecret';" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE django_polls_playwright_demo WITH OWNER demo_app_user;" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "GRANT ALL PRIVILEGES ON DATABASE django_polls_playwright_demo TO demo_app_user;" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "CREATE USER demo_app_tester WITH PASSWORD 'verysecret';" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "ALTER USER demo_app_tester CREATEDB;" 2>/dev/null || true

# Run Django migrations
echo "Running Django migrations..."
cd "$WORKSPACES/django-polls-playwright-demo"
pip install -e . --quiet
python3 manage.py migrate --settings=config.settings

# Install Rails dependencies (sudo needed for system gem path)
echo "Setting up Rails project..."
cd "$WORKSPACES/rails-otel-demo"
sudo gem install bundler
sudo bundle install --quiet

echo ""
echo "=== Multi-Repo Setup Complete ==="
echo "  Django: cd /workspaces/django-polls-playwright-demo"
echo "  Rails:  cd /workspaces/rails-otel-demo"
