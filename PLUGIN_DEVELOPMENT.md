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
- **NEW**: Custom `e2e` (End-to-End) sourceSet with TestNG support

**Usage:**
```groovy
plugins {
    id 'xq-test' version '2.1.2'
}
```

**E2E (End-to-End) SourceSet:**
The plugin automatically creates `e2eMain` and `e2eTest` sourceSets for end-to-end testing:

- **Directory structure:**
  - `e2e/main/java` - E2E utility classes
  - `e2e/main/resources` - E2E resources
  - `e2e/test/java` - E2E test classes (uses TestNG)
  - `e2e/test/resources` - E2E test resources (including TestNG suite XML)

- **Configuration:**
```groovy
e2eTestConfig {
    // Option 1: Use TestNG suite XML file (recommended)
    suiteXmlFile = 'e2e/test/resources/testng-suite.xml'

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
  - `compileE2eMainJava` - Compiles E2E utility classes
  - `compileE2eTestJava` - Compiles E2E test classes
  - `e2eTest` - Runs E2E tests using TestNG (not part of `check` task)

- **Dependencies:**
```groovy
dependencies {
    // E2E main dependencies
    e2eMainImplementation 'org.slf4j:slf4j-api:1.7.36'

    // E2E test dependencies (TestNG and SnakeYAML are included by default)
    e2eTestImplementation 'io.rest-assured:rest-assured:5.3.0'
    e2eTestImplementation 'org.assertj:assertj-core:3.24.2'
}
```

**Example TestNG Suite XML** (`e2e/test/resources/testng-suite.xml`):
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

**Notes:**
- E2E tests are excluded from JaCoCo coverage reports
- e2eTest task is NOT automatically added to the `check` task
- Run E2E tests explicitly with `./gradlew e2eTest`
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