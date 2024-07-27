### Design Document for Content Feed Application

#### Overview
This document outlines the design for the data model of a personal web product that functions as a feed for images, links, and notes. The product allows content to be posted or dropped on the page and displays it in a persistent, organized list. This document focuses on the models, relationships, and how ActiveStorage is utilized for handling file uploads.

### Key Models Overview

1. **ContentItem**: The base model representing any item in the feed, such as images, links, and notes. This model uses Single Table Inheritance (STI) to handle different types of content uniformly.
   - **Attributes**:
     - `id`: Unique identifier
     - `type`: STI type to distinguish between different content types (e.g., Image, Link, Note)
     - `created_at`: Timestamp of when the item was created
     - `updated_at`: Timestamp of when the item was last updated

2. **Image**: Inherits from `ContentItem` and represents image files uploaded to the feed. Utilizes ActiveStorage for handling file attachments.
   - **Attributes**:
     - `metadata`: JSON or other format for storing additional metadata (e.g., dimensions, format)
   - **Associations**:
     - `has_one_attached :file`

3. **Link**: Inherits from `ContentItem` and represents URLs added to the feed with fetched metadata.
   - **Attributes**:
     - `url`: The actual link URL
     - `title`: Title of the linked page
     - `description`: Description or summary of the linked page
     - `thumbnail_url`: URL of the thumbnail image for the link

4. **Note**: Inherits from `ContentItem` and represents text notes added to the feed.
   - **Attributes**:
     - `text`: The content of the note

5. **Tag**: Represents a tag that can be associated with any `ContentItem` for categorization.
   - **Attributes**:
     - `name`: The name of the tag

6. **ContentItemTag**: Joins `ContentItem` and `Tag` to allow many-to-many relationships between content items and tags.
   - **Attributes**:
     - `content_item_id`: Foreign key to `ContentItem`
     - `tag_id`: Foreign key to `Tag`

### Model Relationships

- **ContentItem**: The parent class for `Image`, `Link`, and `Note`. It uses Single Table Inheritance (STI) to handle different types of content.
  - `has_many :content_item_tags`
  - `has_many :tags, through: :content_item_tags`

- **Image, Link, Note**: These inherit from `ContentItem`.
  - `belongs_to :content_item, polymorphic: true`

- **Tag**: Represents a tag that can be applied to content items.
  - `has_many :content_item_tags`
  - `has_many :content_items, through: :content_item_tags`

- **ContentItemTag**: Joins `ContentItem` and `Tag`.
  - `belongs_to :content_item`
  - `belongs_to :tag`

### Detailed Model Structure

**ContentItem**
```ruby
class ContentItem < ApplicationRecord
  has_many :content_item_tags
  has_many :tags, through: :content_item_tags
end
```

**Image**
```ruby
class Image < ContentItem
  has_one_attached :file
  validates :file, presence: true
  # Additional logic for handling images
end
```

**Link**
```ruby
class Link < ContentItem
  validates :url, presence: true
  # Additional logic for fetching and storing metadata
end
```

**Note**
```ruby
class Note < ContentItem
  validates :text, presence: true
  # Additional logic for handling notes
end
```

**Tag**
```ruby
class Tag < ApplicationRecord
  has_many :content_item_tags
  has_many :content_items, through: :content_item_tags
  validates :name, presence: true, uniqueness: true
end
```

**ContentItemTag**
```ruby
class ContentItemTag < ApplicationRecord
  belongs_to :content_item
  belongs_to :tag
end
```

### ActiveStorage Setup

1. **Install ActiveStorage**:
   ```bash
   rails active_storage:install
   rails db:migrate
   ```

2. **Configure Storage Service**: Set up the storage service in `config/storage.yml`. For example, for local storage:
   ```yaml
   local:
     service: Disk
     root: <%= Rails.root.join("storage") %>
   ```

3. **Add ActiveStorage to Models**:
   - In the `Image` model, use `has_one_attached :file`.

### Example Usage with ActiveStorage

**Creating an Image**
```ruby
image = Image.create(file: params[:file])
```

**Creating a Link**
```ruby
link = Link.create(url: 'https://example.com', title: 'Example', description: 'An example link', thumbnail_url: 'https://example.com/thumbnail.jpg')
```

**Creating a Note**
```ruby
note = Note.create(text: 'This is a note')
```

**Querying Content Items**
```ruby
content_items = ContentItem.all
# This will return all content items, regardless of their type

images = Image.all
# This will return only the items of type Image

links = Link.all
# This will return only the items of type Link

notes = Note.all
# This will return only the items of type Note
```

### Implementation Considerations

- **STI Limitations**: With STI, all attributes of different content types are stored in a single table, which can lead to many unused columns in each row. Monitor the table's size and performance.
- **Polymorphic Associations**: If content types become more complex, consider switching to polymorphic associations, which can provide better performance and scalability.
- **Search and Indexing**: Plan for search and indexing strategies to ensure good performance as the dataset grows.
- **Comprehensive Testing**: Ensure thorough testing for all models and interactions, especially with file uploads and metadata fetching.
- **Pagination and Infinite Scrolling**: Implement pagination or infinite scrolling to handle large sets of data gracefully.

### Security Considerations

- **File Validations**: Add validations to ensure only valid file types and sizes are accepted.
- **SQL Injection and XSS**: Protect the application against SQL injection and XSS attacks by using parameterized queries and sanitizing inputs.
- **File Storage Security**: Secure file uploads by validating file types and sizes, and storing files in a secure location.

### Documentation and Future Enhancements

- Maintain thorough documentation for the codebase, especially for complex areas like STI or polymorphic associations.
- Document the reasoning behind architectural decisions to help future developers understand the design choices.
- Consider future enhancements like video support, advanced search capabilities, and mobile optimization.

This design document provides a comprehensive overview of the data model for the content feed application, focusing on user interactions and mechanics while allowing implementation flexibility for future engineers.