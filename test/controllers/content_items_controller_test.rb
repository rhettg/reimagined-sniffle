# frozen_string_literal: true

require 'test_helper'

class ContentItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = content_items(:content_items_one)
    @link = content_items(:content_items_two)
    @note = content_items(:content_items_three)
  end

  test 'should get index' do
    get content_items_url, as: :json
    assert_response :success
    assert_equal 'application/json', @response.media_type
    json_response = JSON.parse(@response.body)
    assert_includes json_response.map { |item| item['type'] }, 'Image'
    assert_includes json_response.map { |item| item['type'] }, 'Link'
    assert_includes json_response.map { |item| item['type'] }, 'Note'
  end

  test 'should get new' do
    get new_content_item_url, as: :json
    assert_response :success
  end

  test 'should create content items' do
    assert_difference('ContentItem.count', 3) do
      # Create Image
      post content_items_url, params: { content_item: { type: 'Image', file: fixture_file_upload('test_image.jpg', 'image/jpeg') } }, as: :json
      assert_response :created
      json_response = JSON.parse(@response.body)
      assert_equal 'Image', json_response['type']

      # Create Link
      post content_items_url, params: { content_item: { type: 'Link', url: 'https://example.com' } }, as: :json
      assert_response :created
      json_response = JSON.parse(@response.body)
      assert_equal 'Link', json_response['type']
      assert_equal 'https://example.com', json_response['url']

      # Create Note
      post content_items_url, params: { content_item: { type: 'Note', text: 'This is a new note' } }, as: :json
      assert_response :created
      json_response = JSON.parse(@response.body)
      assert_equal 'Note', json_response['type']
      assert_equal 'This is a new note', json_response['text']
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
    content_items = [@image, @link, @note]
    updates = [
      { file: fixture_file_upload('test_image.jpg', 'image/jpeg') },
      { url: 'https://updated-example.com' },
      { text: 'Updated note content' }
    ]

    content_items.zip(updates).each do |item, update_params|
      patch content_item_url(item), params: { content_item: update_params }, as: :json
      assert_response :success
      assert_equal 'application/json', @response.media_type
      json_response = JSON.parse(@response.body)

      update_params.each do |key, value|
        assert_equal value.to_s, json_response[key.to_s], "Failed to update #{key} for #{item.type}"
      end
    end
  end

  test 'should destroy content_item' do
    assert_difference('ContentItem.count', -1) do
      delete content_item_url(@image), as: :json
    end
    assert_response :no_content
  end

  test 'should handle validation errors' do
    assert_no_difference('ContentItem.count') do
      post content_items_url, params: { content_item: { type: 'Note', text: '' } }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal 'application/json', @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response['errors'].keys, 'text'
    assert_includes json_response['errors']['text'], "can't be blank"
  end
end
