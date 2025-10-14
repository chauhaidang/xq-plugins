# Implementation Tasks: Custom 'sit' SourceSet for xq-test Plugin

## Overview
Add custom `sit` (System Integration Test) sourceSet support to the xq-test Gradle plugin with TestNG task configuration.

**Goal**: Consumers can automatically have `sit/main/java` and `sit/test/java` directories with pre-configured TestNG test tasks.

---

## Task Breakdown

### Task 1: Enhance TestConfiguration Class
**File**: `plugin/src/main/groovy/TestConfiguration.groovy`

**Objective**: Extend TestConfiguration to support TestNG-specific options.

**Changes**:
```groovy
public class TestConfiguration {
    String path

    // TestNG suite file support (XML or YAML)
    String suiteXmlFile
    String suiteYamlFile

    // TestNG groups configuration
    List<String> includeGroups = []
    List<String> excludeGroups = []

    // Parallel execution
    String parallel = 'none'  // Options: none, methods, tests, classes, instances
    Integer threadCount = 1

    // Test output
    String outputDirectory
    Boolean useDefaultListeners = true
    List<String> listeners = []

    // Additional TestNG options
    Boolean preserveOrder = false
    Boolean groupByInstances = false
    Integer timeOut = 0
    Boolean verbose = false
}
```

**Acceptance Criteria**:
- [ ] All properties added to TestConfiguration class
- [ ] Default values set appropriately
- [ ] Class compiles without errors

---

### Task 2: Add Custom SourceSets to xq-test.gradle
**File**: `plugin/src/main/groovy/xq-test.gradle`

**Objective**: Define `sitMain` and `sitTest` sourceSets at root level (not under src/).

**Changes**:
Add after line 45 (after configurations block):
```groovy
// Custom sourceSets for System Integration Tests
sourceSets {
    sitMain {
        java {
            srcDirs = ['sit/main/java']
        }
        resources {
            srcDirs = ['sit/main/resources']
        }
        compileClasspath += sourceSets.main.output
        runtimeClasspath += sourceSets.main.output
    }

    sitTest {
        java {
            srcDirs = ['sit/test/java']
        }
        resources {
            srcDirs = ['sit/test/resources']
        }
        compileClasspath += sourceSets.sitMain.output + sourceSets.main.output + sourceSets.test.output
        runtimeClasspath += sourceSets.sitMain.output + sourceSets.main.output + sourceSets.test.output
    }
}
```

**Acceptance Criteria**:
- [ ] sitMain sourceSet points to `sit/main/java` (root level)
- [ ] sitTest sourceSet points to `sit/test/java` (root level)
- [ ] Classpath dependencies configured correctly
- [ ] Both sourceSets inherit from main sourceSet

---

### Task 3: Configure Dependencies for sit SourceSets
**File**: `plugin/src/main/groovy/xq-test.gradle`

**Objective**: Add TestNG and necessary dependencies to sit sourceSets.

**Changes**:
Add to dependencies block (after line 38):
```groovy
dependencies {
    // ... existing dependencies ...

    // SIT dependencies
    sitTestImplementation "org.testng:testng:${testng_version}"
    sitTestImplementation 'org.yaml:snakeyaml:2.0'
    sitTestImplementation sourceSets.main.output
    sitTestImplementation sourceSets.sitMain.output
}
```

**Acceptance Criteria**:
- [ ] TestNG added to sitTest scope
- [ ] SnakeYAML added for YAML suite support
- [ ] sitTest can access main and sitMain output
- [ ] Dependencies resolve correctly

---

### Task 4: Create sitTestConfig Extension
**File**: `plugin/src/main/groovy/xq-test.gradle`

**Objective**: Register configuration extension for consumers to customize sitTest behavior.

**Changes**:
Add after line 49 (after existing extensions):
```groovy
// SIT test configuration extension
project.extensions.create("sitTestConfig", TestConfiguration)
```

**Acceptance Criteria**:
- [ ] Extension registered with name "sitTestConfig"
- [ ] Uses enhanced TestConfiguration class
- [ ] Consumers can access via `sitTestConfig { }` block

---

### Task 5: Create sitTest TestNG Task
**File**: `plugin/src/main/groovy/xq-test.gradle`

**Objective**: Create custom TestNG test task with full configuration support.

**Changes**:
Add after the test task configuration (after line 61):
```groovy
// System Integration Test task with TestNG
tasks.register('sitTest', Test) {
    description = 'Runs System Integration Tests using TestNG'
    group = 'verification'

    testClassesDirs = sourceSets.sitTest.output.classesDirs
    classpath = sourceSets.sitTest.runtimeClasspath

    useTestNG() {
        def config = project.extensions.getByName('sitTestConfig') as TestConfiguration

        // Suite file support (XML or YAML)
        if (config.suiteXmlFile) {
            suites(project.file(config.suiteXmlFile))
        }
        if (config.suiteYamlFile) {
            suites(project.file(config.suiteYamlFile))
        }

        // Groups configuration
        if (!config.includeGroups.isEmpty()) {
            includeGroups(config.includeGroups as String[])
        }
        if (!config.excludeGroups.isEmpty()) {
            excludeGroups(config.excludeGroups as String[])
        }

        // Parallel execution
        parallel = config.parallel
        threadCount = config.threadCount

        // Additional TestNG options
        preserveOrder = config.preserveOrder
        groupByInstances = config.groupByInstances
        useDefaultListeners = config.useDefaultListeners

        if (!config.listeners.isEmpty()) {
            listeners = config.listeners
        }

        if (config.verbose) {
            verbose = 1
        }
    }

    // Test reporting
    reports {
        html.required = true
        junitXml.required = true
    }

    testLogging {
        events "passed", "skipped", "failed"
        exceptionFormat = 'full'
        showStandardStreams = false
    }

    // Custom output directory if specified
    afterEvaluate {
        def config = project.extensions.getByName('sitTestConfig') as TestConfiguration
        if (config.outputDirectory) {
            reports.html.outputLocation = project.file(config.outputDirectory)
        }
    }

    // Should run after standard tests but not part of check
    shouldRunAfter tasks.named('test')
}
```

**Acceptance Criteria**:
- [ ] Task named 'sitTest' registered
- [ ] Uses TestNG framework (not JUnit)
- [ ] Reads configuration from sitTestConfig extension
- [ ] Supports XML and YAML suite files
- [ ] Supports TestNG groups (include/exclude)
- [ ] Supports parallel execution configuration
- [ ] Supports custom listeners
- [ ] Generates HTML and JUnit XML reports
- [ ] NOT added to check task
- [ ] Runs after test task (shouldRunAfter)

---

### Task 6: Exclude sit from JaCoCo Coverage
**File**: `plugin/src/main/groovy/xq-test.gradle`

**Objective**: Ensure JaCoCo only covers unit tests, not SIT tests.

**Changes**:
Modify jacocoTestReport task (around line 59-61):
```groovy
tasks.named("jacocoTestReport") {
    dependsOn(tasks.named("test"))

    // Only include main sourceSet, exclude sit
    sourceSets project.sourceSets.main

    // Explicitly exclude sit from coverage
    classDirectories.setFrom(
        files(classDirectories.files.collect {
            fileTree(dir: it, exclude: '**/sit/**')
        })
    )
}
```

**Acceptance Criteria**:
- [ ] JaCoCo report only includes main sourceSet
- [ ] sit sourceSets excluded from coverage
- [ ] Coverage report runs successfully

---

### Task 7: Create Sample Consumer Project for Testing
**Location**: Create test project structure

**Objective**: Validate plugin works correctly in a consumer project.

**Structure**:
```
test-consumer/
├── build.gradle
├── settings.gradle
├── src/
│   ├── main/java/
│   │   └── com/example/Calculator.java
│   └── test/java/
│       └── com/example/CalculatorTest.java
└── sit/
    ├── main/java/
    │   └── com/example/sit/SitHelper.java
    └── test/
        ├── java/
        │   └── com/example/sit/ApiIntegrationTest.java
        └── resources/
            └── testng-suite.xml
```

**build.gradle**:
```groovy
plugins {
    id 'com.xq.xq-test'
}

sitTestConfig {
    includeGroups = ['smoke', 'integration']
    parallel = 'methods'
    threadCount = 4
    verbose = true
}

dependencies {
    implementation 'org.slf4j:slf4j-api:1.7.36'
    sitTestImplementation 'io.rest-assured:rest-assured:5.3.0'
}
```

**Test Cases**:
1. Basic SIT test with TestNG annotations
2. Test using groups (@Test(groups = "smoke"))
3. Test using testng-suite.xml
4. Test accessing sitMain utilities
5. Test parallel execution

**Acceptance Criteria**:
- [ ] Consumer project builds successfully
- [ ] sitMainCompileJava task exists
- [ ] sitTestCompileJava task exists
- [ ] sitTest task executes successfully
- [ ] Tests in sit/test/java are discovered
- [ ] TestNG groups work correctly
- [ ] Suite XML configuration works
- [ ] sit/main/java classes accessible from sit/test/java
- [ ] HTML test report generated
- [ ] JaCoCo excludes sit tests from coverage

---

### Task 8: Build and Publish Plugin
**Objective**: Build updated plugin and make available for testing.

**Commands**:
```bash
cd /Users/automation2/Documents/workspace/project/xq-app/xq-plugins
./gradlew :plugin:clean :plugin:build
./gradlew :plugin:publishToMavenLocal
```

**Acceptance Criteria**:
- [ ] Plugin builds without errors
- [ ] All tests pass
- [ ] Plugin published to Maven Local
- [ ] Version bumped appropriately

---

### Task 9: Create Documentation
**Files**:
- `.claude/agents/SIT_USAGE.md`
- Update `docs/PLUGIN_DEVELOPMENT.md`

**Objective**: Document the new sit sourceSet feature.

**Content**:

**SIT_USAGE.md**:
- Overview of sit sourceSet feature
- Directory structure explanation
- sitTestConfig configuration options
- Usage examples (basic, with groups, with XML/YAML)
- Common patterns and best practices
- Troubleshooting guide

**PLUGIN_DEVELOPMENT.md Update**:
- Add section on sit sourceSet
- Update xq-test plugin features list
- Add configuration examples

**Acceptance Criteria**:
- [ ] SIT_USAGE.md created with comprehensive guide
- [ ] PLUGIN_DEVELOPMENT.md updated
- [ ] All configuration options documented
- [ ] Multiple usage examples provided
- [ ] Best practices included

---

## Implementation Order

1. Task 1: Enhance TestConfiguration Class (foundation)
2. Task 2: Add Custom SourceSets (core feature)
3. Task 3: Configure Dependencies (enables compilation)
4. Task 4: Create sitTestConfig Extension (consumer API)
5. Task 5: Create sitTest Task (main functionality)
6. Task 6: Exclude sit from JaCoCo (cleanup)
7. Task 8: Build and Publish Plugin (make available)
8. Task 7: Test with Consumer Project (validation)
9. Task 9: Create Documentation (finalize)

---

## Testing Checklist

After implementation, verify:
- [ ] Plugin builds successfully
- [ ] sitMain and sitTest sourceSets created
- [ ] sit/main/java and sit/test/java directories recognized
- [ ] sitTest task available
- [ ] TestNG tests execute
- [ ] XML suite configuration works
- [ ] YAML suite configuration works
- [ ] TestNG groups filtering works
- [ ] Parallel execution works
- [ ] sit/main/java classes accessible from tests
- [ ] JaCoCo excludes sit tests
- [ ] HTML reports generated
- [ ] Task does not run with check
- [ ] IDE (IntelliJ) recognizes sourceSets
- [ ] Dependencies resolve correctly

---

## Version Update

Update version in `plugin/build.gradle`:
```groovy
version = '2.1.0'  // Minor version bump for new feature
```

Update README.md version table:
```markdown
| plugin->xq-test | 2.1.0   | Add custom 'sit' sourceSet with TestNG support |
```

---

## Notes

- **sit directory location**: Root level (same as src/), NOT under src/
- **No check task dependency**: sitTest runs independently
- **No coverage**: SIT tests excluded from JaCoCo reports
- **TestNG only**: sitTest uses TestNG framework, not JUnit
- **Flexible configuration**: Supports XML, YAML, and programmatic configuration
- **Groups support**: Full TestNG groups/tags functionality exposed