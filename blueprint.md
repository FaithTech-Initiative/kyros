# Kyros App Blueprint

## Overview

This document outlines the features and implementation plan for the Kyros Bible study app.

## Implemented Features

*   **Bible Reader:**
    *   Browse and read different Bible versions.
    *   Download Bible versions for offline access.
    *   Search for verses within a chapter.
    *   Listen to the audio of a chapter.
*   **Reading History:**
    *   Keeps track of the user's reading history.
*   **My Wiki:**
    *   A personal wiki for taking notes and creating study guides.

## Current Plan: New Features

Here is the plan to implement the new features you requested:

### 1. Daily Verse

*   **Daily Verse Screen:**
    *   Create a new screen to display the daily verse.
    *   Fetch the daily verse from the `https://beta.ourmanna.com/api/v1/get?format=json&order=random` API.
*   **Home Screen Integration:**
    *   Display the daily verse prominently on the home screen.

### 2. Prayer Journal & Notebook

*   **Unified Notes System:**
    *   Implement a single, robust notes system to handle both the prayer journal and the notebook.
*   **Note Model:**
    *   Create a `Note` model with the following attributes: `id`, `title`, `content`, `date`, and `labels`.
*   **Database:**
    *   Set up a local SQLite database to store all notes, ensuring offline access and fast performance.
*   **Note Screens:**
    *   `NotesScreen`: A screen to display a list of all notes.
    *   `NoteEditorScreen`: A screen with a rich text editor for creating and editing notes.
*   **Note Actions:**
    *   Implement full CRUD (Create, Read, Update, Delete) functionality.
    *   Add the ability to "make a copy" of a note.
*   **Labels:**
    *   Allow users to add and manage labels for notes, making it easy to organize and filter them.

### 3. Concordance

*   **Concordance Screen:**
    *   Create a new screen that allows users to search for words and see all the verses where they appear.
*   **Search Index:**
    *   Parse the downloaded Bible versions to create a search index for fast and efficient searching.

### 4. Search Language Selection

*   **Language Setting:**
    *   Add a setting to allow users to select their preferred language for Bible searches.
*   **Integration:**
    *   Use the selected language in both the concordance and the verse search.
