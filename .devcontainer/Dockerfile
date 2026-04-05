FROM mcr.microsoft.com/devcontainers/python:3.12

# Install system dependencies via apt
RUN apt-get update \
    && apt-get install -y \
       postgresql postgresql-client \
       ruby ruby-dev ruby-bundler \
       nodejs npm \
       build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL for trust auth on localhost
RUN PG_VERSION=$(ls /etc/postgresql/) \
    && sed -i 's/^host\s\+all\s\+all\s\+127.0.0.1\/32\s\+scram-sha-256/host    all             all             127.0.0.1\/32            trust/' \
       /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
    && sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" \
       /etc/postgresql/${PG_VERSION}/main/postgresql.conf

# Install latest bundler (apt version lags behind what Gemfile.lock expects)
RUN gem install bundler

# Clone repos to a staging area (DevPod overwrites /workspaces/ with a
# volume mount, so we stage here and copy at container start time)
RUN mkdir -p /opt/prebuilt-repos \
    && git clone https://github.com/wsmoak/rails-otel-demo /opt/prebuilt-repos/rails-otel-demo \
    && git clone https://github.com/wsmoak/django-polls-playwright-demo /opt/prebuilt-repos/django-polls-playwright-demo

# Pre-install Django dependencies
WORKDIR /opt/prebuilt-repos/django-polls-playwright-demo
RUN pip install --upgrade pip && pip install -e .

# Pre-install Rails dependencies
WORKDIR /opt/prebuilt-repos/rails-otel-demo
RUN bundle install

WORKDIR /workspaces
