FROM docker.io/library/ruby:3.3-alpine

# Remove all default gems and install bundler
RUN cd "$(echo 'puts Gem.default_specifications_dir' | ruby)" \
    && rm -rf * \
    && gem install bundler

# Install build dependencies
RUN apk add build-base

# Copy the main executable
COPY ./ocidibs.rb /ocidibs.rb

# Change the default config file location
ENV OCI_CONFIG_FILE=/config

# Run the executable
ENTRYPOINT ["ruby", "/ocidibs.rb"]
