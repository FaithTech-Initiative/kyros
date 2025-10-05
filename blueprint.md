
# Project Blueprint

## Overview

This document outlines the style, design, and features of a note-taking and sermon preparation application. The app is designed to be a flexible, focused workspace that supports the entire lifecycle of a note, from initial idea to a polished document. It integrates Bible study tools to create a seamless workflow for users in a faith-based context.

## Core Design Philosophy

*   **Distraction-Free Interface:** The UI is clean, showing only what is necessary for the task at hand to minimize cognitive load.
*   **Support for Multiple Modalities:** The app accommodates both linear (drafting) and spatial (brainstorming) thought processes.
*   **Facilitates Rewriting:** The design encourages users to refine and rewrite notes, which is a key principle for clarifying ideas and aiding memory.

## App Architecture

*   **Main Screen:** A central screen (`main_screen.dart`) that hosts the primary navigation and `AppBar`.
*   **Bottom Navigation:** A `BottomNavigationBar` with four main tabs:
    *   **Home:** A dashboard or landing page.
    *   **Bible:** A dedicated screen for reading and searching the Bible.
    *   **Study Tools:** A collection of tools to aid in study.
    *   **My Wiki:** A personal knowledge base or index of notes.
*   **App Bar:** A consistent `AppBar` across all main screens, featuring:
    *   A menu icon to open a side drawer.
    *   A search icon that toggles a search bar within the `AppBar`.
    *   A profile avatar.
*   **Side Drawer:** A navigation drawer for access to settings, profile, and other secondary pages.

## Style and Design

*   **Theme:** Material 3 with a custom color scheme.
*   **Color Palette:**
    *   Primary Color (Seed): Teal (`0xFF008080`)
    *   Secondary Color: Lilac (`0xFFC8A2C8`)
    *   Light Background: Alice Blue (`0xFFF0F8FF`)
    *   Dark Background: Dark Slate Blue (`0xFF29465B`)
*   **Typography:** Custom fonts using the `google_fonts` package.
*   **Mode:** Supports both light and dark modes with a toggle.
*   **App Icon:** A custom app icon has been generated and applied to both Android and iOS platforms.

## Features

### 1. Home Screen

*   Placeholder for a future dashboard or overview of recent notes and activity.

### 2. Note-Taking Screen

*   **Block-Based Editor:** A flexible editor where every paragraph, list, or heading is a movable, "atomic" block.
*   **Integrated Bible Panel:** A collapsible side panel for Bible reference, displayed alongside the note editor on wider screens.

### 3. Bible Screen

*   A dedicated interface for reading and searching the full text of the Bible.

### 4. Study Tools Screen

*   Placeholder for future study tools like concordances, commentaries, or dictionaries.

### 5. My Wiki Screen

*   A personal, searchable knowledge base built from the user's notes and tags.

## Current Plan

*   **Goal:** Refine UI by removing the debug banner and the "Notes" item from the navigation bar.
*   **Steps:**
    1. Set `debugShowCheckedModeBanner` to `false` in `main.dart`.
    2. Remove the "Notes" `BottomNavigationBarItem` from `main_screen.dart`.
    3. Update the `_widgetOptions` list in `main_screen.dart`.
    4. Update the blueprint.
