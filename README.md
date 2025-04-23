# XQ Plugins 
![Latest build result](https://github.com/chauhaidang/xq-plugins/actions/workflows/ci.yml/badge.svg?branch=main)

A Gradle-based project for building and managing plugins with centralized dependency management using the Gradle platform feature.

## Plugins & platform version
| Name     | Version | Last change                          |
|----------|---------|--------------------------------------|
| xq-dev   | 2.0.0   | Change default jar file name         |
| xq-test  | 1.0.1   | Plugin reuse platform() dependencies |
| platform | 1.0.0   | Initial release                      |

## Project Structure

- **`platform`**: Defines centralized dependency constraints using the Gradle Java Platform Plugin.
- **`plugin`**: Contains the plugin implementation and configurations.

## Features

- Centralized dependency management with Gradle platform.
- Plugin development with support for Java, Groovy, and Spring Boot.
- Predefined test configurations (unit, integration, and component tests).
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