# Sniffle

Sniffle is a personal web-based feed application for organizing and displaying various types of content, including images, text, and links. The primary goal is to create a minimal and efficient tool for personal use, leveraging a Rails stack with Turbo and Stimulus for the front end, and using Tailwind for CSS.

## Overview

Sniffle allows content to be posted or dropped on the page and displays it in a persistent, organized list. The application supports multiple content types and provides features for content interaction and organization.

## Features and Functionality

### Core Features
- **Content Types**:
  - Images (initial support)
  - Text (including notes)
  - Links (with metadata fetching, embedded YouTube videos, and embedded tweets)
  - Future support for videos

- **Content Interaction**:
  - Ability to tag content for better organization
  - Notes can be added to any content item
  - Ability to remove items from the feed

- **Content Organization**:
  - Tagging system for categorizing content
  - Date and time metadata displayed subtly
  - Feed displayed in reverse chronological order (most recent items first)

- **Content Handling**:
  - Drag and drop for uploading files
  - Text box for pasting links or typing notes
  - Infinite scrolling for seamless content viewing
  - Search functionality (later priority)

- **APIs**:
  - RSS feed for the content
  - JSON API for accessing the feed

## Technical Implementation

### Front-End
- **Framework**: Turbo and Stimulus for interactivity
- **CSS Framework**: Tailwind CSS for a clean and modern design

### Back-End
- **Framework**: Rails 7 for handling requests, data storage, and API endpoints
- **Database**: SQLite for storing content metadata and tags
- **Storage**: Local file system for storing uploaded images and media

### APIs
- **RSS Feed**: Generated from the content feed, providing a way to subscribe to updates
- **JSON API**: Endpoint to access the feed data programmatically

## Future Considerations
- **Video Support**: Adding support for video uploads and playback
- **Advanced Search**: Implementing more robust search capabilities
- **Additional Content Types**: Expanding to support documents and other media types
- **Mobile Optimization**: Ensuring the interface is fully responsive and works well on mobile devices

## Getting Started

### Ruby version
- Ruby 3.2.0

### System dependencies
- SQLite for the database
- Local file system for media storage

### Configuration
- Ensure you have the correct Ruby version installed using rbenv

### Database creation
- Run `script/setup` to set up the database

### Database initialization
- Run `script/setup` to initialize the database

### How to run the test suite
- Run `script/test` to execute the test suite

### Services (job queues, cache servers, search engines, etc.)
- Not applicable at this stage

### Deployment instructions
- Not applicable at this stage

For more detailed information, refer to the `docs/product.md` file.
