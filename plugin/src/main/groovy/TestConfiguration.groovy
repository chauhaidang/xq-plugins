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
