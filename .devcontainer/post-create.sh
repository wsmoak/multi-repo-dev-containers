#!/bin/bash
set -e

echo "=== OpenSWE Multi-Repo Dev Environment Setup ==="

# Install system dependencies via apt (no GHCR features)
echo "Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
  postgresql postgresql-client \
  ruby ruby-dev ruby-bundler \
  nodejs npm \
  build-essential libpq-dev
sudo rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL for trust auth on localhost
PG_VERSION=$(ls /etc/postgresql/)
PG_HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"
sudo sed -i 's/^host\s\+all\s\+all\s\+127.0.0.1\/32\s\+scram-sha-256/host    all             all             127.0.0.1\/32            trust/' "$PG_HBA"
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" "$PG_CONF"

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

# Clone repos into /workspaces
echo ""
echo "=== Cloning repositories ==="

WORKSPACES="/workspaces"

if [ ! -d "$WORKSPACES/rails-otel-demo" ]; then
  echo "Cloning rails-otel-demo..."
  git clone https://github.com/wsmoak/rails-otel-demo "$WORKSPACES/rails-otel-demo"
fi

if [ ! -d "$WORKSPACES/django-polls-playwright-demo" ]; then
  echo "Cloning django-polls-playwright-demo..."
  git clone https://github.com/wsmoak/django-polls-playwright-demo "$WORKSPACES/django-polls-playwright-demo"
fi

# Setup Django project
echo ""
echo "=== Setting up Django project ==="
cd "$WORKSPACES/django-polls-playwright-demo"

# Create Django database users and databases
psql -U postgres -h 127.0.0.1 -c "CREATE USER demo_app_user WITH PASSWORD 'supersecret';" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE django_polls_playwright_demo WITH OWNER demo_app_user;" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "GRANT ALL PRIVILEGES ON DATABASE django_polls_playwright_demo TO demo_app_user;" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "CREATE USER demo_app_tester WITH PASSWORD 'verysecret';" 2>/dev/null || true
psql -U postgres -h 127.0.0.1 -c "ALTER USER demo_app_tester CREATEDB;" 2>/dev/null || true

pip install --upgrade pip
pip install -e .
python3 manage.py migrate --settings=config.settings

# Setup Rails project
echo ""
echo "=== Setting up Rails project ==="
cd "$WORKSPACES/rails-otel-demo"
bundle install
# Rails setup will be extended once rails-otel-demo has its own devcontainer needs

echo ""
echo "=== Multi-Repo Setup Complete ==="
echo "  Django: cd /workspaces/django-polls-playwright-demo"
echo "  Rails:  cd /workspaces/rails-otel-demo"
