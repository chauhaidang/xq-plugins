package com.example.sit;

import com.example.Calculator;
import org.testng.annotations.*;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * Simple System Integration Test to verify TestNG configuration.
 * Demonstrates TestNG groups, parallel execution, and lifecycle methods.
 */
public class SimpleIntegrationTest {

    @BeforeClass
    public void setupClass() {
        System.out.println("=== BeforeClass: Setting up SimpleIntegrationTest ===");
    }

    @BeforeMethod
    public void setupMethod() {
        System.out.println("  @BeforeMethod executed");
    }

    @Test(groups = {"smoke"}, description = "Smoke test - basic arithmetic")
    public void testBasicArithmetic() {
        System.out.println("Running testBasicArithmetic [smoke]");
        assertThat(1 + 1).isEqualTo(2);
        assertThat(10 * 5).isEqualTo(50);
    }

    @Test(groups = {"integration"}, description = "Integration test - Calculator class")
    public void testCalculatorIntegration() {
        System.out.println("Running testCalculatorIntegration [integration]");
        Calculator calc = new Calculator();
        assertThat(calc.add(5, 3)).isEqualTo(8);
        assertThat(calc.multiply(4, 5)).isEqualTo(20);
    }

    @Test(groups = {"smoke", "integration"}, description = "Test in both groups - String operations")
    public void testStringOperations() {
        System.out.println("Running testStringOperations [smoke, integration]");
        assertThat("hello".toUpperCase()).isEqualTo("HELLO");
        assertThat("WORLD".toLowerCase()).isEqualTo("world");
    }

    @Test(groups = {"integration"}, description = "Integration test - SitHelper")
    public void testSitHelper() {
        System.out.println("Running testSitHelper [integration]");
        SitHelper helper = new SitHelper();
        String response = helper.callApi("/api/test");
        assertThat(response).contains("/api/test");
        assertThat(helper.validateResponse(response)).isTrue();
    }

    @Test(groups = {"smoke"}, description = "Smoke test - SitHelper validation")
    public void testSitHelperValidation() {
        System.out.println("Running testSitHelperValidation [smoke]");
        SitHelper helper = new SitHelper();
        assertThat(helper.validateResponse("valid")).isTrue();
        assertThat(helper.validateResponse("")).isFalse();
        assertThat(helper.validateResponse(null)).isFalse();
    }

    @AfterMethod
    public void cleanupMethod() {
        System.out.println("  @AfterMethod executed");
    }

    @AfterClass
    public void cleanupClass() {
        System.out.println("=== AfterClass: Cleaning up SimpleIntegrationTest ===");
    }
}
