#!/bin/sh

# PERFORM LOGROTATE CONFIGURATION
# Limits the size of the log files to 1MB and keeps only 20 backups

# Create logrotate configuration for Nginx
# Use 'cat <<EOF' to create the logrotate configuration file for Nginx
cat <<EOF > /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    size 1M
    missingok
    rotate 20
    compress
    delaycompress
    notifempty
    create 0640 nginx adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 $(cat /var/run/nginx.pid)
    endscript
}
EOF

# Start logrotate in the background
logrotate -f /etc/logrotate.d/nginx &

# Start Nginx in the foreground to keep the container running
nginx -g 'daemon off;'