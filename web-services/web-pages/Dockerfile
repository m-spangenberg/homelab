# BUILD NGINX DOCKER IMAGE WITH LOGROTATE SUPPORT

FROM docker.io/nginx:latest

# Install logrotate
RUN apt-get update && apt-get install -y logrotate && rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]