# Kyros Bible App Blueprint

## Overview

This document outlines the architecture, features, and development plan for the Kyros Bible App. The goal is to create a beautiful, performant, and easy-to-use mobile application for reading and studying the Bible.

The application will now leverage Firebase Firestore to store and manage Bible versions, allowing for a scalable and dynamic content delivery system.

## Style, Design, and Features

### Core Features
*   **Bible Reading:** Clean and readable interface for browsing books, chapters, and verses.
*   **Version Management:** Users can browse available Bible translations and download them for offline access.
*   **Search:** Full-text search within the selected Bible version.
*   **History:** Keeps track of recently viewed chapters.
*   **User Authentication:** (Future) Allow users to sign in to sync notes, bookmarks, and highlights.
*   **Notes & Highlighting:** (Future) Tools for users to interact with the text.

### Data & Backend (New)
*   **Primary Database:** Firebase Firestore.
*   **Data Structure:**
    *   `versions` (Collection): Stores metadata for each available Bible translation.
        *   *Document ID:* `KJV`, `ASV`, etc.
        *   *Fields:* `name: "King James Version"`, `language: "en"`, `year: 1611`.
    *   `bibles` (Collection): Contains the actual text content for each version.
        *   *Document ID:* `KJV`, `ASV`, etc.
        *   *Sub-collection:* `books`
            *   *Document ID:* `Genesis`, `Exodus`, etc.
            *   *Fields:* A map of chapters, where each chapter contains a list of verse objects.
                ```json
                {
                  "1": [
                    { "verse": 1, "text": "In the beginning..." },
                    { "verse": 2, "text": "..." }
                  ],
                  "2": [ ... ]
                }
                ```
*   **Offline Storage:** A local SQLite database on the device to store downloaded Bible versions for offline reading.

### UI/UX
*   **Theme:** Material 3 design with support for both light and dark modes.
*   **Typography:** Clean, readable fonts.
*   **Navigation:** Intuitive navigation between the main library, reader view, and settings.

## Current Plan: Firestore Integration

**Objective:** Migrate Bible content storage from local assets and external zip files to Firebase Firestore.

**Steps:**

1.  **[In Progress] Setup Firebase:**
    *   Add `firebase_core` and `cloud_firestore` dependencies.
    *   Guide the user to configure their project with `flutterfire configure`.
    *   Initialize Firebase in `lib/main.dart`.

2.  **[Pending] Data Migration:**
    *   Create a one-time Dart script (`tool/upload_bibles.dart`).
    *   This script will read all JSON files from the `assets/translations` directory.
    *   It will parse and transform the data to fit the new Firestore structure.
    *   It will then upload all versions, books, and verses to Firestore.

3.  **[Pending] Refactor Services:**
    *   Create a new `FirestoreService` to handle all communication with Firestore (fetching version lists, downloading book content).
    *   Modify `DatabaseHelper` to use `FirestoreService` as its data source for creating and updating the local SQLite database.
    *   Remove the old logic for downloading and unzipping files via HTTP.

4.  **[Pending] Update UI:**
    *   Update `BibleVersionsScreen` to fetch the list of available translations from the `versions` collection in Firestore.
    *   Ensure the "Download" button correctly triggers the new Firestore -> SQLite data flow.
