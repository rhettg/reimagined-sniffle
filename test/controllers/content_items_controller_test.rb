# frozen_string_literal: true

require 'test_helper'

class ContentItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = content_items(:content_items_two)
    @link = content_items(:content_items_three)
    @note = content_items(:content_items_one)
  end

  test 'should get index' do
    # Create an image content item
    Image.create!(title: "Test Image")

    get content_items_url, as: :json
    assert_response :success
    assert_equal 'application/json', @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response.map { |item| item['type'] }, 'Image'
    assert_includes json_response.map { |item| item['type'] }, 'Link'
    assert_includes json_response.map { |item| item['type'] }, 'Note'

    # Verify that the created image is in the response
    assert json_response.any? { |item| item['type'] == 'Image' && item['title'] == 'Test Image' }
  end

  test 'should get new' do
    get new_content_item_url, as: :json
    assert_response :success
  end

  test 'should create content items' do
    assert_difference('ContentItem.count', 3) do
      # Create Image
      post content_items_url, params: { content_item: { type: 'Image', title: 'Test Image' } }, as: :json
      assert_response :created
      json_response = JSON.parse(@response.body)
      assert_equal 'Image', json_response['type']
      assert_equal 'Test Image', json_response['title']

      # Create Link
      post content_items_url, params: { content_item: { type: 'Link', url: 'https://example.com' } }, as: :json
      assert_response :created
      json_response = JSON.parse(@response.body)
      assert_equal 'Link', json_response['type']
      assert_equal 'https://example.com', json_response['url']

      # Create Note
      post content_items_url, params: { content_item: { type: 'Note', content: 'This is a new note' } }, as: :json
      assert_response :created
      json_response = JSON.parse(@response.body)
      assert_equal 'Note', json_response['type']
      assert_equal 'This is a new note', json_response['content']
    end
  end

  test 'should show content_item' do
    [@image, @link, @note].each do |item|
      get content_item_url(item), as: :json
      assert_response :success
      assert_equal 'application/json', @response.media_type
      json_response = JSON.parse(@response.body)
      assert_equal item.type, json_response['type']
    end
  end

  test 'should get edit' do
    [@image, @link, @note].each do |item|
      get edit_content_item_url(item), as: :json
      assert_response :success
    end
  end

  test 'should update content_item' do
    patch content_item_url(@image), params: { content_item: { title: 'Updated Image Title' } }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 'Updated Image Title', json_response['title']

    patch content_item_url(@link), params: { content_item: { url: 'https://updated-example.com' } }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 'https://updated-example.com', json_response['url']

    patch content_item_url(@note), params: { content_item: { content: 'Updated note content' } }, as: :json
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 'Updated note content', json_response['content']
  end

  test 'should destroy content_item' do
    assert_difference('ContentItem.count', -1) do
      delete content_item_url(@image), as: :json
    end
    assert_response :no_content
  end

  test 'should handle validation errors for Note' do
    assert_no_difference('ContentItem.count') do
      post content_items_url, params: { content_item: { type: 'Note', content: '' } }, as: :json
      assert_response :unprocessable_entity
    end

    assert_equal 'application/json', @response.media_type

    json_response = JSON.parse(@response.body)
    assert_kind_of Hash, json_response
    assert_includes json_response.keys, 'errors'
    assert_includes json_response['errors'].keys, 'content'
    assert_includes json_response['errors']['content'], "can't be blank"
  end

  test 'should create image with file attachment' do
    assert_difference('ContentItem.count') do
      file = fixture_file_upload(Rails.root.join('test', 'fixtures', 'files', 'test_image.jpg'), 'image/jpeg')
      post content_items_url, params: {
        content_item: {
          type: 'Image',
          title: 'Test Image with File',
          file: file
        }
      }, as: :json
      assert_response :created
      puts "Response body: #{response.body}"
    end

    json_response = JSON.parse(@response.body)
    assert_equal 'Image', json_response['type']
    assert_equal 'Test Image with File', json_response['title']
    assert_not_nil json_response['file_url']

    created_image = ContentItem.find(json_response['id'])
    puts "Created image attributes: #{created_image.attributes}"
    assert created_image.file.attached?
    assert_equal 'image/jpeg', created_image.file.content_type
    assert_equal 'test_image.jpg', created_image.file.filename.to_s

    # Verify the file can be accessed
    get json_response['file_url']
    assert_response :success
    assert_equal 'image/jpeg', response.content_type
  end
end
