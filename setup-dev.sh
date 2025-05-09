#!/bin/bash

# Deploy pods
echo "Deploying Pods..."
cd dev-services/
for service in "${dev-services[@]}"; do
    cd $service
    podman-compose up -d
    cd ..
done
