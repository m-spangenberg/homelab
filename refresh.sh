#!/bin/bash

# Deploy pods
echo "Refreshing Pods..."
cd dev-services/

# Stop all running pods
podman pods stop --all

for service in "${dev-services[@]}"; do
    cd $service
    docker compose pull
    cd ..
done

for service in "${local-services[@]}"; do
    cd $service
    docker compose up -d --remove-orphans
    cd ..
done

for service in "${dev-services[@]}"; do
    cd $service
    docker compose up -d --remove-orphans
    cd ..
done