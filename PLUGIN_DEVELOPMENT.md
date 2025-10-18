# Plugin Development Guide

This guide covers how to develop, test, and publish Gradle plugins in the XQ Plugins project.

## Available Plugins

### xq-dev Plugin
Full-featured development plugin for Spring Boot applications with comprehensive testing support.

**Features:**
- Spring Boot 3.3.0 integration
- Java 17 toolchain
- JUnit 5 & TestNG support
- JaCoCo code coverage
- Karate API testing framework
- Lombok annotation processing
- Predefined JAR naming (`app.jar`)

**Usage:**
```groovy
plugins {
    id 'com.xq.xq-dev'
}
```

### xq-test Plugin
Lightweight testing plugin without Spring Boot dependency.

**Features:**
- Java 17 toolchain
- JUnit 5 & TestNG support
- JaCoCo code coverage
- Karate API testing framework
- Lombok annotation processing
- Configurable test suites (unit, integration, component)
- **NEW**: Custom `sit` (System Integration Test) sourceSet with TestNG support

**Usage:**
```groovy
plugins {
    id 'xq-test' version '2.1.0'
}
```

**SIT (System Integration Test) SourceSet:**
The plugin automatically creates `sitMain` and `sitTest` sourceSets for system integration testing:

- **Directory structure:**
  - `sit/main/java` - SIT utility classes
  - `sit/main/resources` - SIT resources
  - `sit/test/java` - SIT test classes (uses TestNG)
  - `sit/test/resources` - SIT test resources (including TestNG suite XML)

- **Configuration:**
```groovy
sitTestConfig {
    // Option 1: Use TestNG suite XML file (recommended)
    suiteXmlFile = 'sit/test/resources/testng-suite.xml'

    // Option 2: Programmatic configuration
    includeGroups = ['smoke', 'integration']
    excludeGroups = ['slow']
    parallel = 'methods'  // none, methods, tests, classes, instances
    threadCount = 4
    verbose = true

    // Additional TestNG options
    preserveOrder = false
    groupByInstances = false
    useDefaultListeners = true
    listeners = ['com.example.CustomTestListener']
}
```

- **Tasks:**
  - `compileSitMainJava` - Compiles SIT utility classes
  - `compileSitTestJava` - Compiles SIT test classes
  - `sitTest` - Runs SIT tests using TestNG (not part of `check` task)

- **Dependencies:**
```groovy
dependencies {
    // SIT main dependencies
    sitMainImplementation 'org.slf4j:slf4j-api:1.7.36'

    // SIT test dependencies (TestNG and SnakeYAML are included by default)
    sitTestImplementation 'io.rest-assured:rest-assured:5.3.0'
    sitTestImplementation 'org.assertj:assertj-core:3.24.2'
}
```

**Example TestNG Suite XML** (`sit/test/resources/testng-suite.xml`):
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

**Notes:**
- SIT tests are excluded from JaCoCo coverage reports
- sitTest task is NOT automatically added to the `check` task
- Run SIT tests explicitly with `./gradlew sitTest`
- TestNG lifecycle methods (@BeforeClass, @AfterClass) work best with XML suite files

## Test Configuration

Both plugins support three test configuration types:

### Unit Tests
```groovy
unitTest {
    // Configuration for unit tests
}
```

### Integration Tests
```groovy
intTest {
    // Configuration for integration tests
}
```

### Component Tests
```groovy
compTest {
    // Configuration for component tests
}
```

## Test Execution

The plugins configure tests with:
- **Parallel execution**: 4 forks
- **Heap size**: 1GB
- **Platform**: JUnit Platform (Jupiter)
- **Coverage**: Automatic JaCoCo reports

## Building Plugins

### Local Development
```bash
./gradlew build
```

### Publishing to Maven Local
```bash
./gradlew publishToMavenLocal
```

### Publishing to GitHub Packages
```bash
export GITHUB_ACTOR=your-username
export GITHUB_TOKEN=your-token
./gradlew publish
```

## Plugin Versioning

Version information is maintained in `plugin/build.gradle`:
```groovy
group = 'com.xq'
version = '2.0.3'
```

## Dependency Versions

Key dependency versions are defined as extension properties:
- `springboot_version`: 3.3.0
- `lombok_version`: 1.18.30
- `junit_version`: 5.11.3
- `testng_version`: 7.9.0
- `slf4j_version`: 1.7.36

## Best Practices

1. **Version Management**: Update versions in a single location
2. **Test Coverage**: Aim for >80% code coverage
3. **Parallel Testing**: Leverage parallel execution for faster builds
4. **JAR Naming**: Use meaningful names or stick with defaults
5. **Documentation**: Keep plugin features documented

## References

- [Gradle Plugin Development](https://docs.gradle.org/current/userguide/custom_plugins.html)
- [Spring Boot Gradle Plugin](https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/htmlsingle/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [TestNG Documentation](https://testng.org/doc/documentation-main.html)
- [JaCoCo Gradle Plugin](https://docs.gradle.org/current/userguide/jacoco_plugin.html)