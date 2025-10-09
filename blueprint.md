
# Project Blueprint

## Overview

This document outlines the style, design, and features of a note-taking and sermon preparation application. The app is designed to be a flexible, focused workspace that supports the entire lifecycle of a note, from initial idea to a polished document. It integrates Bible study tools to create a seamless workflow for users in a faith-based context.

## Core Design Philosophy

*   **Distraction-Free Interface:** The UI is clean, showing only what is necessary for the task at hand to minimize cognitive load.
*   **Support for Multiple Modalities:** The app accommodates both linear (drafting) and spatial (brainstorming) thought processes.
*   **Facilitates Rewriting:** The design encourages users to refine and rewrite notes, which is a key principle for clarifying ideas and aiding memory.

## App Architecture

*   **Main Screen:** A central screen (`main_screen.dart`) that hosts the primary navigation, `AppBar`, and `FloatingActionButton`.
*   **App Drawer:** A navigation drawer (`widgets/app_drawer.dart`) provides access to secondary screens like Profile and Settings.
*   **Bottom Navigation:** A `BottomNavigationBar` with four main tabs:
    *   **Home:** A dashboard or landing page.
    *   **Bible:** A dedicated screen for reading and searching the Bible.
    *   **Study Tools:** A collection of tools to aid in study.
    *   **Collections:** A personal knowledge base or index of notes.
*   **Floating Action Button:** Provides a quick way to create a new note, navigating to the `NoteTakingPage`.
*   **State Management:** The `provider` package is used for state management, with providers for `ThemeProvider`, `FontSizeProvider`, and `NotificationProvider`.
*   **Routing:** The application uses named routes for navigation.
*   **Authentication Service:** An `AuthService` class (`lib/services/auth_service.dart`) encapsulates all authentication logic, including email/password, Google, and Apple sign-in.
*   **Utilities:** A `lib/utils` directory contains helper functions, such as `snackbar_helper.dart` for showing consistent `SnackBar` messages.

## Style and Design

*   **Theme:** The app uses Material 3 design principles. A custom `ThemeData` object in `main.dart` defines the app's visual style, managed by a `ThemeProvider`.
*   **Color Palette:** Harmonious light and dark color schemes are generated from a single seed color (`Colors.deepPurple`) using `ColorScheme.fromSeed`.
*   **Typography:** The `google_fonts` package is used to apply custom fonts (`Oswald`, `Roboto`, `Open Sans`) to the app's `TextTheme`. Font sizes are dynamically adjustable by the user.
*   **Mode:** Supports both light and dark modes, which can be toggled in the Settings screen.
*   **App Icon:** A custom app icon has been generated and applied.

## Features

### 1. Main Navigation

*   **App Drawer:** Provides access to the `ProfileScreen` and `SettingsScreen`.
*   **Bottom Navigation:** Allows switching between `HomeScreen`, `BibleLookupScreen`, `StudyToolsScreen`, and `CollectionsScreen`.

### 2. Screens

*   **Get Started Screen:** A beautiful landing screen with a background image and a prominent "Get Started" button that navigates the user to the authentication flow.
*   **Authentication Screen:** A screen that allows users to sign in or sign up using email/password, Google, or Apple. It also includes a "Continue as Guest" option. It features robust error handling, provides loading indicators during asynchronous operations, and gives clear user feedback via SnackBars.
*   **Home Screen:** A dashboard displaying a list of recent notes and a `FloatingActionButton` to create new ones.
*   **Note-Taking Screen:** A dedicated page for creating and editing notes.
*   **Bible Lookup Screen:** A placeholder for a future Bible reading and searching interface.
*   **Study Tools Screen:** A placeholder for future study tools.
*   **Collections Screen:** A placeholder for a personal knowledge base.
*   **Profile Screen:** A functional screen allowing users to manage their profile. It includes a `CircleAvatar` to select a profile image from the gallery, `TextFormField`s for name and email, and a button to save changes.
*   **Settings Screen:** A comprehensive screen where users can:
    *   Toggle between light and dark themes.
    *   Adjust the application's font size via a slider.
    *   Enable or disable notifications.

## Current Plan

*   **Goal:** Improve Code Quality and Idiomatic Dart/Flutter in `AuthScreen`
*   **Status:** **Completed**
*   **Steps:**
    1.  Removed the redundant `onSaved` callback for the password field and used the `_passwordController` directly.
    2.  Created a `_setAuthMode` method to handle toggling between login and sign-up, reducing code duplication.
    3.  Applied other minor fixes to make the code more robust and idiomatic.
