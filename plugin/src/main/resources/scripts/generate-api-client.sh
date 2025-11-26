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

# Check if publishing should be skipped (default: false)
if [ -z "$SKIP_PUBLISH" ]; then
    SKIP_PUBLISH="false"
fi

# Use GROUP_ID from environment if set, otherwise use default
if [ -z "$GROUP_ID" ]; then
    GROUP_ID="com.xqfitness.client"
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

# Find Java 17 installation
find_java17() {
    # Check if JAVA_HOME is already set to Java 17
    if [ -n "$JAVA_HOME" ]; then
        if [ -f "$JAVA_HOME/bin/java" ]; then
            local java_version=$("$JAVA_HOME/bin/java" -version 2>&1 | head -n 1 | grep -oE 'version "1[7-9]|version "2[0-5]' | grep -oE '1[7-9]|2[0-5]' || echo "")
            if [ "$java_version" = "17" ]; then
                log_info "Using existing JAVA_HOME (Java 17): $JAVA_HOME"
                echo "$JAVA_HOME"
                return 0
            fi
        fi
    fi
    
    # Try to find Java 17 using /usr/libexec/java_home (macOS)
    if command -v /usr/libexec/java_home &> /dev/null; then
        local java17_home=$(/usr/libexec/java_home -v 17 2>/dev/null)
        if [ -n "$java17_home" ] && [ -d "$java17_home" ]; then
            log_info "Found Java 17 via java_home: $java17_home"
            echo "$java17_home"
            return 0
        fi
    fi
    
    # Check common Java installation locations
    local java17_paths=(
        "/usr/lib/jvm/java-17"
        "/usr/lib/jvm/java-17-openjdk"
        "/usr/lib/jvm/java-17-openjdk-amd64"
        "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home"
    )
    
    for path in "${java17_paths[@]}"; do
        if [ -d "$path" ] && [ -f "$path/bin/java" ]; then
            local java_version=$("$path/bin/java" -version 2>&1 | head -n 1 | grep -oE 'version "1[7-9]|version "2[0-5]' | grep -oE '1[7-9]|2[0-5]' || echo "")
            if [ "$java_version" = "17" ]; then
                log_info "Found Java 17: $path"
                echo "$path"
                return 0
            fi
        fi
    done
    
    # Check SDKMAN installations
    if [ -d "$HOME/.sdkman/candidates/java" ]; then
        for java_dir in "$HOME/.sdkman/candidates/java"/17*; do
            if [ -d "$java_dir" ] && [ -f "$java_dir/bin/java" ]; then
                local java_version=$("$java_dir/bin/java" -version 2>&1 | head -n 1 | grep -oE 'version "1[7-9]|version "2[0-5]' | grep -oE '1[7-9]|2[0-5]' || echo "")
                if [ "$java_version" = "17" ]; then
                    log_info "Found Java 17 via SDKMAN: $java_dir"
                    echo "$java_dir"
                    return 0
                fi
            fi
        done
    fi
    
    log_warning "Java 17 not found. OpenAPI Generator will use system Java."
    echo ""
    return 1
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

    # Find and use Java 17 for OpenAPI Generator
    local java17_home=$(find_java17)
    local original_java_home="$JAVA_HOME"
    if [ -n "$java17_home" ] && [ -d "$java17_home" ]; then
        export JAVA_HOME="$java17_home"
        export PATH="$JAVA_HOME/bin:$PATH"
        log_info "Using Java 17 for OpenAPI Generator: $JAVA_HOME"
    else
        log_warning "Java 17 not found. OpenAPI Generator will use system Java."
    fi

    # Generate Java client using OpenAPI Generator
    # The java17=true property ensures Java 17 compatible code generation
    # Using webclient library for modern Spring 5+ reactive support
    openapi-generator-cli generate \
        -i "$api_file" \
        -g java \
        -o "$output_dir" \
        --library webclient \
        --group-id "$GROUP_ID" \
        --artifact-id "${service_name}-client" \
        --api-package ${GROUP_ID}.${service_name}.api \
        --model-package ${GROUP_ID}.${service_name}.model \
        --invoker-package ${GROUP_ID}.${service_name}.invoker \
        --additional-properties=java17=true,dateLibrary=java8,hideGenerationTimestamp=true,useJakartaEe=true

    # Restore original JAVA_HOME if it was set
    if [ -n "$original_java_home" ]; then
        export JAVA_HOME="$original_java_home"
    fi

    log_success "Client generated for $service_name"
    
    # Fix Java version compatibility issue in generated build.gradle
    fix_build_gradle "$output_dir"
}

# Fix generated build.gradle to handle Java version compatibility
fix_build_gradle() {
    local client_dir=$1
    local build_gradle="$client_dir/build.gradle"
    
    if [ ! -f "$build_gradle" ]; then
        log_warning "build.gradle not found in $client_dir, skipping fix"
        return
    fi
    
    log_info "Fixing Java version compatibility in build.gradle..."
    
    # Check if build.gradle already has java toolchain configuration
    if grep -q "java.toolchain\|JavaLanguageVersion" "$build_gradle"; then
        log_info "Java toolchain already configured in build.gradle"
        return
    fi
    
    # Add Java toolchain configuration after "apply plugin: 'maven-publish'"
    # This ensures Gradle uses a compatible Java version
    if grep -q "apply plugin: 'java'" "$build_gradle"; then
        log_info "Adding Java toolchain configuration to build.gradle"
        
        # Create a Python script or use a more reliable method
        # For now, let's use a simple approach: insert after maven-publish line
        local temp_file=$(mktemp)
        local inserted=false
        
        while IFS= read -r line; do
            echo "$line" >> "$temp_file"
            # Insert toolchain config after "apply plugin: 'maven-publish'"
            if [[ "$line" == *"apply plugin: 'maven-publish'"* ]] && [ "$inserted" = false ]; then
                echo "" >> "$temp_file"
                echo "    java {" >> "$temp_file"
                echo "        toolchain {" >> "$temp_file"
                echo "            languageVersion = JavaLanguageVersion.of(17)" >> "$temp_file"
                echo "        }" >> "$temp_file"
                echo "    }" >> "$temp_file"
                inserted=true
            fi
        done < "$build_gradle"
        
        if [ "$inserted" = true ]; then
            mv "$temp_file" "$build_gradle"
            log_success "build.gradle updated with Java toolchain configuration"
        else
            rm "$temp_file"
            log_warning "Could not find insertion point for Java toolchain configuration"
        fi
    fi
}

# Publish client to Maven local repository
publish_client() {
    local client_dir=$1
    local service_name=$(basename "$client_dir")

    log_info "Publishing $service_name client to Maven local repository..."

    if [ ! -d "$client_dir" ]; then
        log_error "Client directory does not exist: $client_dir"
        return 1
    fi

    cd "$client_dir" || {
        log_error "Failed to change directory to $client_dir"
        return 1
    }

    if [ ! -f "./gradlew" ]; then
        log_error "Gradle wrapper not found in $client_dir"
        return 1
    fi

    chmod +x ./gradlew

    # Remove build directory to ensure clean rebuild with correct Java version
    # This fixes "Unsupported class file major version" errors
    if [ -d "build" ]; then
        log_info "Removing build directory to ensure clean rebuild..."
        rm -rf build
    fi

    # Set JVM args to suppress native access warnings (Java 17+)
    # Preserve existing GRADLE_OPTS if set
    if [ -z "$GRADLE_OPTS" ]; then
        export GRADLE_OPTS="--enable-native-access=ALL-UNNAMED"
    else
        export GRADLE_OPTS="${GRADLE_OPTS} --enable-native-access=ALL-UNNAMED"
    fi

    log_info "Running: ./gradlew clean build publishToMavenLocal -x test"
    if ./gradlew clean build publishToMavenLocal -x test; then
        log_success "$service_name client published to Maven local repository"
        return 0
    else
        log_error "Failed to publish $service_name client to Maven local repository"
        return 1
    fi
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

        # Publish to Maven local (unless skipped)
        if [ "$SKIP_PUBLISH" != "true" ]; then
            if ! publish_client "$client_dir"; then
                log_error "Failed to publish $service_name client. Continuing with other clients..."
                log_warning "Error occurred while publishing client for $service_name. See above logs for details. Continuing with other clients."
                # Continue processing other clients even if one fails
            fi
        else
            log_info "Skipping publishing for $service_name (SKIP_PUBLISH=true)"
        fi
    done

    log_success "All clients generated and published successfully!"
    log_info "Generated clients location: $GENERATED_CLIENTS_DIR"
    log_info ""
    log_info "To use the clients in your project, add to build.gradle:"
    for api_file in "${api_files[@]}"; do
        local service_name=$(basename "$api_file" | sed 's/-api\.yaml$//' | sed 's/-api\.yml$//')
        log_info "  implementation '${GROUP_ID}:${service_name}-client:1.0.0'"
    done
}

# Run main function
main "$@"
