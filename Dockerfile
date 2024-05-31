# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    node-gyp \
    pkg-config \
    python-is-python3 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install nodejs and yarn
ARG NODE_VERSION=20.14.0
ARG YARN_VERSION=1.22.22
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install application gems
RUN bundle install --without development test && \
    rm -rf ${BUNDLE_PATH}/ruby/*/cache && \
    bundle exec bootsnap precompile --gemfile

# Copy the rest of the application code
COPY . .

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN SECRET_KEY_BASE_DUMMY=1 DEVISE_SECRET_KEY=e4b7d3c9a0f96a8f ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=base /usr/local/bundle /usr/local/bundle
COPY --from=base /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
