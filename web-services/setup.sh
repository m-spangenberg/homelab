#!/bin/bash

# Deploy pods
echo "Deploying Pods..."
cd web-services/
for service in "${web-services[@]}"; do
    cd $service
    podman-compose up -d
    cd ..
done
