# XQ Plugins 
![Latest build result](https://github.com/chauhaidang/xq-plugins/actions/workflows/ci.yml/badge.svg?branch=main)


A Gradle-based project for building and managing plugins.

## Plugins & platform version
| Name            | Version | Last change                                          |
|-----------------|---------|------------------------------------------------------|
| plugin          | 2.1.3   | Rename 'sit' to 'e2e' sourceSet                      |
| plugin->xq-dev  | 2.1.3   | No changes (synced version)                          |
| plugin->xq-test | 2.1.3   | Rename 'sit' to 'e2e' sourceSet                      |

## Project Structure

- **`plugin`**: Contains the plugin implementation and configurations.

## Features

- Plugin development with support for Java, Groovy, and Spring Boot.
- Predefined test configurations (unit, integration, component, and end-to-end tests).
- **NEW in v2.1.0**: Custom `e2e` (End-to-End) sourceSet with TestNG support
  - Automatic TestNG test task configuration
  - Support for XML/YAML suite files
  - TestNG groups filtering (include/exclude)
  - Parallel execution support
  - Custom test listeners
  - Excluded from JaCoCo coverage reports
- **NEW in v2.2.0**: API Client Generation from OpenAPI/Swagger definitions
  - Automatic Java client generation using OpenAPI Generator
  - Support for multiple API definition files
  - Configurable output directory and Maven coordinates
  - Automatic publishing to Maven Local repository
  - Jakarta EE and Java 17 support
- Customizable build and test tasks.
- Predefined JAR naming for the plugin.

## Requirements

- **Java**: 17 or higher
- **Gradle**: 8.13 or higher

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/chauhaidang/xq-plugins.git
cd xq-plugins
```

### Build the Project

```bash
./gradlew build
```

### Publish to Maven Local

```bash
./gradlew publishToMavenLocal
```

## Using the Plugins

### xq-test Plugin with E2E Support

Apply the plugin in your `build.gradle`:

```groovy
plugins {
    id 'xq-test' version '2.1.3'
}
```

#### End-to-End (E2E) Test Setup

Create the E2E directory structure at the **root level** of your project:

```
your-project/
├── src/
│   ├── main/java/
│   └── test/java/
└── e2e/
    ├── main/java/          # E2E utility classes
    ├── main/resources/     # E2E resources
    ├── test/java/          # E2E test classes (TestNG)
    └── test/resources/     # TestNG suite XML files
```

#### Configure E2E Tests

In your `build.gradle`:

```groovy
e2eTestConfig {
    // Option 1: Use TestNG suite XML file (recommended)
    suiteXmlFile = 'e2e/test/resources/testng-suite.xml'

    // Option 2: Programmatic configuration
    includeGroups = ['smoke', 'integration']
    excludeGroups = ['slow']
    parallel = 'methods'  // Options: none, methods, tests, classes, instances
    threadCount = 4
    verbose = true
}

dependencies {
    // Add E2E-specific dependencies
    e2eMainImplementation 'org.slf4j:slf4j-api:1.7.36'
    e2eTestImplementation 'io.rest-assured:rest-assured:5.3.0'
}
```

#### Example TestNG Suite XML

Create `e2e/test/resources/testng-suite.xml`:

```xml
<!DOCTYPE suite SYSTEM "https://testng.org/testng-1.0.dtd" >
<suite name="End-to-End Test Suite" verbose="1" parallel="methods" thread-count="4">
    <test name="E2E Tests">
        <groups>
            <run>
                <include name="smoke"/>
                <include name="integration"/>
            </run>
        </groups>
        <classes>
            <class name="com.example.e2e.ApiIntegrationTest"/>
        </classes>
    </test>
</suite>
```

#### Run E2E Tests

```bash
# Run only E2E tests
./gradlew e2eTest

# Run all tests including E2E
./gradlew test e2eTest

# Note: e2eTest is NOT part of the check task
./gradlew check  # Does NOT run e2eTest
```

#### Available E2E Tasks

- `compileE2eMainJava` - Compile E2E utility classes
- `compileE2eTestJava` - Compile E2E test classes
- `e2eTest` - Execute E2E tests using TestNG

### API Client Generation

The xq-test plugin includes a powerful API client generation task that creates Java clients from OpenAPI/Swagger definition files.

#### Prerequisites

Install OpenAPI Generator CLI globally:

```bash
npm install -g @openapitools/openapi-generator-cli
```

#### Configuration

In your `build.gradle`:

```groovy
apiClientGeneration {
    // Required: List of API definition files (YAML or JSON)
    apiDefinitionFiles = [
        'src/main/resources/api/user-api.yaml',
        'src/main/resources/api/order-api.yaml'
    ]

    // Optional: Output directory (defaults to 'generated-clients')
    outputDirectory = 'generated-clients'

    // Optional: Maven group ID (defaults to 'com.xqfitness.client')
    groupId = 'com.mycompany.client'

    // Optional: Skip publishing to Maven Local (defaults to false)
    skipPublish = false
}
```

#### Generate Clients

```bash
# Generate API clients from configured definition files
./gradlew generateApiClient

# The task will:
# 1. Validate all API definition files exist
# 2. Generate Java clients using OpenAPI Generator
# 3. Publish generated clients to Maven Local repository
# 4. Display usage instructions
```

#### Using Generated Clients

After generation, add the clients as dependencies:

```groovy
dependencies {
    implementation 'com.mycompany.client:user-client:1.0.0'
    implementation 'com.mycompany.client:order-client:1.0.0'
}
```

#### Generated Client Features

The generated clients include:
- **RestTemplate** based HTTP client
- **Jakarta EE** annotations (Spring Boot 3.x compatible)
- **Java 17** features support
- Type-safe API and model classes
- Request/response models with validation
- Complete JavaDoc documentation

## Publishing

### Automatic Publishing to GitHub Packages

The project uses GitHub Actions to automatically publish plugins to GitHub Packages when the version changes in `plugin/build.gradle`.

**How it works**:
1. Update the version in `plugin/build.gradle` (e.g., from `2.1.0` to `2.1.1`)
2. Commit and push to the `main` branch
3. GitHub Actions will:
   - Detect the version change
   - Build the project
   - Publish to GitHub Packages (only if build succeeds)
   - Create a Git tag (e.g., `v2.1.1`)

**Manual publishing** (for local development):
```bash
./gradlew publishToMavenLocal
```

## Documentation

For detailed plugin development and usage information, see:
- [Plugin Development Guide](PLUGIN_DEVELOPMENT.md) - Comprehensive plugin documentation
- [Claude Assistant Guide](CLAUDE.md) - AI assistant instructions for this project

## License

This project is licensed under the Apache License 2.0