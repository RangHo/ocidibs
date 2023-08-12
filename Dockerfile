FROM docker.io/library/ruby:alpine

# Copy the main executable
COPY ./ocidibs.rb /ocidibs.rb

# Run the executable
ENTRYPOINT ["ruby", "/ocidibs.rb"]
