#!/bin/bash
set -e

echo "=== OpenSWE Multi-Repo Post-Create ==="

WORKSPACES="/workspaces"
PREBUILT="/opt/prebuilt-repos"

# Copy prebuilt repos into /workspaces (fast local copy vs network clone),
# then pull to pick up any commits since the image was built.
for repo in rails-otel-demo django-polls-playwright-demo agent-projects; do
  if [ ! -d "$WORKSPACES/$repo/.git" ]; then
    if [ -d "$PREBUILT/$repo" ]; then
      echo "Copying prebuilt $repo..."
      cp -a "$PREBUILT/$repo" "$WORKSPACES/$repo"
    else
      echo "Cloning $repo (no prebuilt available)..."
      git clone "https://github.com/wsmoak/$repo" "$WORKSPACES/$repo"
    fi
  fi
  echo "Pulling latest $repo..."
  git -C "$WORKSPACES/$repo" pull --ff-only || true
done

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

# Run Django migrations (dependencies pre-installed in image)
echo "Running Django migrations..."
cd "$WORKSPACES/django-polls-playwright-demo"
pip install -e . --quiet
python3 manage.py migrate --settings=config.settings

# Update Rails dependencies if needed (gems pre-installed in image)
echo "Updating Rails dependencies..."
cd "$WORKSPACES/rails-otel-demo"
sudo bundle install --quiet

echo ""
echo "=== Multi-Repo Setup Complete ==="
echo "  Django: cd /workspaces/django-polls-playwright-demo"
echo "  Rails:  cd /workspaces/rails-otel-demo"
