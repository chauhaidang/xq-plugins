import org.gradle.api.provider.ListProperty
import org.gradle.api.provider.Property

/**
 * Extension for configuring API client generation from OpenAPI/Swagger definitions.
 * <p>
 * This extension allows users to specify API definition files and customize the
 * code generation process using the OpenAPI Generator.
 * </p>
 *
 * <p>Example usage:</p>
 * <pre>
 * apiClientGeneration {
 *     apiDefinitionFiles = [
 *         'src/main/resources/api/user-api.yaml',
 *         'src/main/resources/api/order-api.yaml'
 *     ]
 *     outputDirectory = 'generated-clients'
 *     groupId = 'com.xqfitness.client'
 *     skipPublish = false
 * }
 * </pre>
 *
 * @since 2.2.0
 */
abstract class ApiClientGenerationExtension {

    /**
     * List of API definition files (YAML/JSON) to generate clients from.
     * <p>
     * Paths can be relative to the project root or absolute.
     * Files should follow OpenAPI 3.x specification.
     * </p>
     */
    abstract ListProperty<String> getApiDefinitionFiles()

    /**
     * Output directory for generated clients.
     * <p>
     * Defaults to 'generated-clients' in the project root.
     * </p>
     */
    abstract Property<String> getOutputDirectory()

    /**
     * Maven group ID for generated client artifacts.
     * <p>
     * Defaults to 'com.xqfitness.client'.
     * </p>
     */
    abstract Property<String> getGroupId()

    /**
     * Whether to skip publishing generated clients to Maven Local.
     * <p>
     * Defaults to false (clients will be published).
     * </p>
     */
    abstract Property<Boolean> getSkipPublish()

    /**
     * Whether to clean the output directory before generation.
     * <p>
     * Defaults to true (output directory will be cleaned).
     * </p>
     */
    abstract Property<Boolean> getCleanOutput()

    /**
     * Additional OpenAPI Generator properties.
     * <p>
     * These properties are passed to the generator via --additional-properties flag.
     * Defaults include: java17=true, dateLibrary=java8, hideGenerationTimestamp=true, useJakartaEe=true
     * </p>
     */
    abstract Property<String> getAdditionalProperties()

    /**
     * Java client library: 'webclient' (Spring WebFlux) or 'rest-assured'.
     * <p>
     * Defaults to 'webclient'. Use 'rest-assured' for component tests with Rest Assured.
     * </p>
     */
    abstract Property<String> getLibrary()

    ApiClientGenerationExtension() {
        // Set defaults
        apiDefinitionFiles.convention([])
        outputDirectory.convention('generated-clients')
        groupId.convention('com.xqfitness.client')
        skipPublish.convention(false)
        cleanOutput.convention(true)
        additionalProperties.convention('java17=true,dateLibrary=java8,hideGenerationTimestamp=true,useJakartaEe=true')
        library.convention('webclient')
    }
}
