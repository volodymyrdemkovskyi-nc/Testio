### README.md


# Great iOS Developer Task

This repository contains a sample iOS application developed as part of the "Great iOS Developer" task. The app features a 2-screen interface: a Login screen and a Server List screen, designed to meet the provided technical requirements and closely replicate the design from the Figma file.

## Overview

- Login Screen: Allows users to log in using predefined credentials to obtain an authorization token.
- Server List Screen: Displays a list of servers fetched after successful login, with persistent storage and sorting options.
- Credential Storage: Optional implementation using Keychain for seamless app restarts.
- Networking: Handles API requests to authenticate and fetch server data.
- Persistence: Uses SwiftData for storing server information.
- Testing: Includes unit and integration tests for core functionality.

## Features

- Authentication: Sends a POST request to https://playground.nordsec.com/v1/tokens with credentials {"username": "tesonet", "password": "partyanimal"} to obtain a Bearer token.
- Server Fetching: GET request to https://playground.nordsec.com/v1/servers with Authorization: Bearer <token> header.
- Error Handling: Manages 401 Unauthorized responses by prompting re-login.
- Persistence: Stores server data using SwiftData for offline access.
- Design: Replicated from the Figma design at [https://www.figma.com/file/NEqPdYxCcxnB5b1ByahrXU/Great-task-for-Great-iOS-Developer](https://www.figma.com/file/NEqPdYxCcxnB5b1ByahrXU/Great-task-for-Great-iOS-Developer?node-id=0%3A1) (requires sign-up for editable assets).
- Animation: Logo on the Login screen features a smooth 25% scale animation that pulses and returns to its original size.
- Bonus: Credential storage implemented using Keychain for automatic login on app restart.

## Project Structure

- `AppConfigurator.swift`: Centralizes constants for sizes, images, URLs, strings, colors, and fonts.
- `LoginView.swift`: Implements the login screen with an animated logo and form.
- `LoginViewModel.swift`: Manages login logic and authentication.
- `ServersView.swift`: Displays the server list with sorting capabilities.
- `ServersViewModel.swift`: Handles server data fetching, sorting, and persistence.
- `Server.swift`: Model class for server data with SwiftData integration.
- `NetworkManager.swift`: Manages network requests with protocol-based mocking.
- `Tests`: Contains unit and integration tests for LoginViewModel, ServersViewModel, Server, and NetworkManager.

## Setup Instructions

1. Clone the Repository:
   

   git clone <repository-url>
   cd <repository-folder>
   

2. Install Dependencies:
   - This project uses native Swift and SwiftUI with no external dependencies. Ensure you have Xcode 15+ installed.

3. Open the Project:
   - Open Testio.xcodeproj in Xcode.

4. Build and Run:
   - Select a simulator or device and press Cmd + R to build and run.

5. Configuration:
   - No additional configuration is required. The app uses hardcoded credentials for the task.

## Testing

Run tests via Xcode:
- Select Cmd + U or go to Product > Test to execute all test cases.
- Tests cover authentication, server fetching, sorting, persistence, and error handling.

## Design Notes

The UI is crafted to match the Figma design closely, with attention to:
- Layout and spacing defined in AppConfigurator.Sizes.
- Color scheme from AppConfigurator.Colors.
- Typography from AppConfigurator.Fonts.
- Animated logo effect implemented in AnimatedLogo component.

## Best Practices

- MVVM Architecture: Used for clean separation of concerns.
- Protocol-Oriented Programming: For network layer flexibility.
- SwiftUI: Leveraged for declarative UI with animations.
- Error Handling: Robust 401 response management.
- Test Coverage: High-quality tests for reliability.

## How to Submit

1. Archive the project:
   - In Xcode, go to Product > Archive.
   - Export the archive as an .xcarchive or .ipa file.
2. Send the archive to the provided contact via email or upload link.

## Contact

For questions or feedback, reach out to the task provider with the submitted archive.

## License

This project is created for evaluation purposes and is not licensed for public use.
