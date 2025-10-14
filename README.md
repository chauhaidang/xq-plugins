# XQ Plugins 
![Latest build result](https://github.com/chauhaidang/xq-plugins/actions/workflows/ci.yml/badge.svg?branch=main)


A Gradle-based project for building and managing plugins.

## Plugins & platform version
| Name            | Version | Last change                                          |
|-----------------|---------|------------------------------------------------------|
| plugin          | 2.1.0   | Add custom 'sit' sourceSet with TestNG support      |
| plugin->xq-dev  | 2.0.0   | Change default jar file name                         |
| plugin->xq-test | 2.1.0   | Add custom 'sit' sourceSet with TestNG support       |

## Project Structure

- **`plugin`**: Contains the plugin implementation and configurations.

## Features

- Plugin development with support for Java, Groovy, and Spring Boot.
- Predefined test configurations (unit, integration, component, and system integration tests).
- **NEW in v2.1.0**: Custom `sit` (System Integration Test) sourceSet with TestNG support
  - Automatic TestNG test task configuration
  - Support for XML/YAML suite files
  - TestNG groups filtering (include/exclude)
  - Parallel execution support
  - Custom test listeners
  - Excluded from JaCoCo coverage reports
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

### xq-test Plugin with SIT Support

Apply the plugin in your `build.gradle`:

```groovy
plugins {
    id 'xq-test' version '2.1.0'
}
```

#### System Integration Test (SIT) Setup

Create the SIT directory structure at the **root level** of your project:

```
your-project/
├── src/
│   ├── main/java/
│   └── test/java/
└── sit/
    ├── main/java/          # SIT utility classes
    ├── main/resources/     # SIT resources
    ├── test/java/          # SIT test classes (TestNG)
    └── test/resources/     # TestNG suite XML files
```

#### Configure SIT Tests

In your `build.gradle`:

```groovy
sitTestConfig {
    // Option 1: Use TestNG suite XML file (recommended)
    suiteXmlFile = 'sit/test/resources/testng-suite.xml'

    // Option 2: Programmatic configuration
    includeGroups = ['smoke', 'integration']
    excludeGroups = ['slow']
    parallel = 'methods'  // Options: none, methods, tests, classes, instances
    threadCount = 4
    verbose = true
}

dependencies {
    // Add SIT-specific dependencies
    sitMainImplementation 'org.slf4j:slf4j-api:1.7.36'
    sitTestImplementation 'io.rest-assured:rest-assured:5.3.0'
}
```

#### Example TestNG Suite XML

Create `sit/test/resources/testng-suite.xml`:

```xml
<!DOCTYPE suite SYSTEM "https://testng.org/testng-1.0.dtd" >
<suite name="System Integration Test Suite" verbose="1" parallel="methods" thread-count="4">
    <test name="SIT Tests">
        <groups>
            <run>
                <include name="smoke"/>
                <include name="integration"/>
            </run>
        </groups>
        <classes>
            <class name="com.example.sit.ApiIntegrationTest"/>
        </classes>
    </test>
</suite>
```

#### Run SIT Tests

```bash
# Run only SIT tests
./gradlew sitTest

# Run all tests including SIT
./gradlew test sitTest

# Note: sitTest is NOT part of the check task
./gradlew check  # Does NOT run sitTest
```

#### Available SIT Tasks

- `compileSitMainJava` - Compile SIT utility classes
- `compileSitTestJava` - Compile SIT test classes
- `sitTest` - Execute SIT tests using TestNG

## Documentation

For detailed plugin development and usage information, see:
- [Plugin Development Guide](PLUGIN_DEVELOPMENT.md) - Comprehensive plugin documentation
- [Claude Assistant Guide](CLAUDE.md) - AI assistant instructions for this project

## License

This project is licensed under the Apache License 2.0