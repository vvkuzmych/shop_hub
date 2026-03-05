# Production Dockerfile for Rails Backend
FROM docker.io/library/ruby:3.3.6-slim AS base

# Install base dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libpq-dev \
    libyaml-dev \
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

WORKDIR /rails

# Build stage - install gems
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage - minimal production image
FROM base

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run as non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

USER rails:rails

# Entrypoint prepares database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port
EXPOSE 3000

# Start server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
