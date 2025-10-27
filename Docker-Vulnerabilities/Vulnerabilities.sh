#!/bin/bash

# Name of the image you want to build and scan
image_name="api"
context_dir=""  # Directory of the Dockerfile, adjust if necessary

# Build the Docker image
docker build -t "$image_name" "$context_dir"
if [ $? -ne 0 ]; then
  echo "Error building the Docker image."
  exit 1
fi

echo "Docker image '$image_name' built successfully."

# Scan the image with Trivy
echo "Scanning the image with Trivy..."
trivy image --severity CRITICAL,HIGH,MEDIUM,LOW --exit-code 1 "$image_name"

# Check the scan results
if [ $? -ne 0 ]; then
  echo "Vulnerabilities detected in image '$image_name'."
  exit 1
else
  echo "No critical, high, or medium vulnerabilities found."
  exit 0
fi