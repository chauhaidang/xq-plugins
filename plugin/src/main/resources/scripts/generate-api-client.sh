#!/bin/bash

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use environment variables if set, otherwise calculate defaults
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

if [ -z "$GENERATED_CLIENTS_DIR" ]; then
    GENERATED_CLIENTS_DIR="$PROJECT_ROOT/generated-clients"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if OpenAPI Generator is installed
check_openapi_generator() {
    if ! command -v openapi-generator-cli &> /dev/null; then
        log_error "OpenAPI Generator CLI is not installed!"
        log_info "Please install it globally using npm:"
        log_info "  npm install -g @openapitools/openapi-generator-cli"
        log_info "Installing OpenAPI Generator CLI..."
        npm install -g @openapitools/openapi-generator-cli
        log_success "OpenAPI Generator CLI installed successfully!"
    fi

    local version=$(openapi-generator-cli version 2>&1 | head -n 1 || echo "unknown")
    log_info "Using OpenAPI Generator: $version"
}

# Generate client for a single API definition
generate_client() {
    local api_file=$1
    local service_name=$(basename "$api_file" | sed 's/-api\.yaml$//' | sed 's/-api\.yml$//')
    local output_dir="$GENERATED_CLIENTS_DIR/$service_name"

    log_info "Generating client for $service_name from $api_file"

    # Clean previous generation
    if [ -d "$output_dir" ]; then
        log_info "Cleaning previous generated code at $output_dir"
        rm -rf "$output_dir"
    fi

    mkdir -p "$output_dir"

    # Generate Java client using OpenAPI Generator
    openapi-generator-cli generate \
        -i "$api_file" \
        -g java \
        -o "$output_dir" \
        --library resttemplate \
        --group-id com.xqfitness.client \
        --artifact-id "${service_name}-client" \
        --api-package com.xqfitness.client.${service_name}.api \
        --model-package com.xqfitness.client.${service_name}.model \
        --invoker-package com.xqfitness.client.${service_name}.invoker \
        --additional-properties=java17=true,dateLibrary=java8,hideGenerationTimestamp=true,useJakartaEe=true

    log_success "Client generated for $service_name"
}

# Publish client to Maven local repository
publish_client() {
    local client_dir=$1
    local service_name=$(basename "$client_dir")

    log_info "Publishing $service_name client to Maven local repository..."

    cd "$client_dir"

    # Check if gradlew exists, if not use gradle command
    if [ -f "./gradlew" ]; then
        chmod +x ./gradlew
        ./gradlew clean build publishToMavenLocal -x test
    elif [ -f "pom.xml" ]; then
        # For Maven-based generation
        mvn clean install -DskipTests
    else
        log_error "No build tool found in $client_dir"
        return 1
    fi

    log_success "$service_name client published to Maven local repository"
}

# Main execution
main() {
    log_info "Starting API client generation and publishing..."
    log_info "Project root: $PROJECT_ROOT"
    log_info "Generated clients directory: $GENERATED_CLIENTS_DIR"

    # Check if OpenAPI Generator is installed
    check_openapi_generator

    # Find all API definition files
    local api_files=()

    # Check for specific API files passed as arguments
    if [ $# -gt 0 ]; then
        # Use provided files
        for arg in "$@"; do
            if [ -f "$arg" ]; then
                api_files+=("$arg")
            elif [ -f "$PROJECT_ROOT/$arg" ]; then
                api_files+=("$PROJECT_ROOT/$arg")
            else
                log_warning "File not found: $arg"
            fi
        done
    else
        # Auto-discover API definition files in project root
        log_info "Searching for API definition files..."
        while IFS= read -r -d '' file; do
            api_files+=("$file")
        done < <(find "$PROJECT_ROOT" -maxdepth 1 \( -name "*-api.yaml" -o -name "*-api.yml" \) -print0)
    fi

    if [ ${#api_files[@]} -eq 0 ]; then
        log_error "No API definition files found!"
        log_info "Usage: $0 [api-file1.yaml] [api-file2.yaml] ..."
        log_info "Or place *-api.yaml or *-api.yml files in the project root"
        exit 1
    fi

    log_info "Found ${#api_files[@]} API definition file(s)"

    # Create generated-clients directory
    mkdir -p "$GENERATED_CLIENTS_DIR"

    # Generate and publish each client
    for api_file in "${api_files[@]}"; do
        log_info "Processing $(basename "$api_file")..."

        # Extract service name from API file
        local service_name=$(basename "$api_file" | sed 's/-api\.yaml$//' | sed 's/-api\.yml$//')
        local client_dir="$GENERATED_CLIENTS_DIR/$service_name"

        # Generate client
        generate_client "$api_file"

        # Publish to Maven local
        publish_client "$client_dir"
    done

    log_success "All clients generated and published successfully!"
    log_info "Generated clients location: $GENERATED_CLIENTS_DIR"
    log_info ""
    log_info "To use the clients in your project, add to build.gradle:"
    for api_file in "${api_files[@]}"; do
        local service_name=$(basename "$api_file" | sed 's/-api\.yaml$//' | sed 's/-api\.yml$//')
        log_info "  implementation 'com.xqfitness.client:${service_name}-client:1.0.0'"
    done
}

# Run main function
main "$@"
