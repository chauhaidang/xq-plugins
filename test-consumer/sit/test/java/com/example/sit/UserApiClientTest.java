package com.example.sit;

import com.xqfitness.client.user.api.UsersApi;
import com.xqfitness.client.user.invoker.ApiClient;
import com.xqfitness.client.user.model.User;
import com.xqfitness.client.user.model.CreateUserRequest;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration test to verify the generated User API client is accessible and symbols are recognized.
 */
public class UserApiClientTest {

    private UsersApi usersApi;

    @BeforeClass
    public void setupClass() {
        System.out.println("=== Setting up UserApiClientTest ===");
        
        // Create API client instance
        ApiClient apiClient = new ApiClient();
        apiClient.setBasePath("https://api.example.com/v1");
        
        // Create UsersApi instance
        usersApi = new UsersApi(apiClient);
        
        System.out.println("UserApiClient initialized successfully");
    }

    @Test(groups = {"integration"}, description = "Verify generated client classes are accessible")
    public void testClientClassesAccessible() {
        System.out.println("Running testClientClassesAccessible [integration]");
        
        // Initialize if not already done (defensive check)
        if (usersApi == null) {
            ApiClient apiClient = new ApiClient();
            apiClient.setBasePath("https://api.example.com/v1");
            usersApi = new UsersApi(apiClient);
        }
        
        // Verify that we can instantiate the API class
        assertThat(usersApi).isNotNull();
        assertThat(usersApi).isInstanceOf(UsersApi.class);
        
        System.out.println("✓ UsersApi class is accessible");
    }

    @Test(groups = {"integration"}, description = "Verify model classes are accessible")
    public void testModelClassesAccessible() {
        System.out.println("Running testModelClassesAccessible [integration]");
        
        // Test User model
        User user = new User();
        user.setId("123");
        user.setEmail("test@example.com");
        user.setFirstName("John");
        user.setLastName("Doe");
        
        assertThat(user).isNotNull();
        assertThat(user.getId()).isEqualTo("123");
        assertThat(user.getEmail()).isEqualTo("test@example.com");
        assertThat(user.getFirstName()).isEqualTo("John");
        assertThat(user.getLastName()).isEqualTo("Doe");
        
        System.out.println("✓ User model class is accessible and functional");
        
        // Test CreateUserRequest model
        CreateUserRequest createRequest = new CreateUserRequest();
        createRequest.setEmail("newuser@example.com");
        createRequest.setFirstName("Jane");
        createRequest.setLastName("Smith");
        
        assertThat(createRequest).isNotNull();
        assertThat(createRequest.getEmail()).isEqualTo("newuser@example.com");
        assertThat(createRequest.getFirstName()).isEqualTo("Jane");
        assertThat(createRequest.getLastName()).isEqualTo("Smith");
        
        System.out.println("✓ CreateUserRequest model class is accessible and functional");
    }

    @Test(groups = {"smoke"}, description = "Verify API client can be instantiated")
    public void testApiClientInstantiation() {
        System.out.println("Running testApiClientInstantiation [smoke]");
        
        // Test ApiClient instantiation
        ApiClient apiClient = new ApiClient();
        assertThat(apiClient).isNotNull();
        
        // Test setting base path
        apiClient.setBasePath("https://api.example.com/v1");
        assertThat(apiClient.getBasePath()).isEqualTo("https://api.example.com/v1");
        
        System.out.println("✓ ApiClient can be instantiated and configured");
    }
}

