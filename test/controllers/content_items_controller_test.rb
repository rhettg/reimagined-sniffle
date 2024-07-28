# frozen_string_literal: true

require 'test_helper'

class ContentItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content_item = ContentItem.create!(type: 'ContentItem')
  end

  test 'should get index' do
    get content_items_url, as: :json
    assert_response :success
  end

  test 'should get new' do
    get new_content_item_url, as: :json
    assert_response :success
  end

  test 'should create content_item' do
    assert_difference('ContentItem.count') do
      post content_items_url, params: { content_item: { type: 'ContentItem' } }, as: :json
    end

    assert_redirected_to content_item_url(ContentItem.last)
  end

  test 'should show content_item' do
    get content_item_url(@content_item), as: :json
    assert_response :success
  end

  test 'should get edit' do
    get edit_content_item_url(@content_item), as: :json
    assert_response :success
  end

  test 'should update content_item' do
    patch content_item_url(@content_item), params: { content_item: { type: 'ContentItem' } }, as: :json
    assert_redirected_to content_item_url(@content_item)
  end

  test 'should destroy content_item' do
    assert_difference('ContentItem.count', -1) do
      delete content_item_url(@content_item), as: :json
    end

    assert_response :no_content
  end

  private

  def content_items_url
    '/content_items'
  end

  def new_content_item_url
    '/content_items/new'
  end

  def edit_content_item_url(content_item)
    "/content_items/#{content_item.id}/edit"
  end

  def content_item_url(content_item)
    "/content_items/#{content_item.id}"
  end
end
