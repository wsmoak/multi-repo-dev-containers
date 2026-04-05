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
