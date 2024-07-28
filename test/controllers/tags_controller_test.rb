# frozen_string_literal: true

require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:tags_one)
    @content_item = content_items(:content_items_one)
  end

  test 'should get index' do
    get tags_url, as: :json
    assert_response :success
  end

  test 'should get new' do
    get new_tag_url, as: :json
    assert_response :success
  end

  test 'should create tag' do
    assert_difference('Tag.count') do
      post tags_url, params: { tag: { name: 'Example tag' } }, as: :json
    end

    assert_redirected_to tag_url(Tag.last)
  end

  test 'should show tag' do
    get tag_url(@tag), as: :json
    assert_response :success
  end

  test 'should get edit' do
    get edit_tag_url(@tag), as: :json
    assert_response :success
  end

  test 'should update tag' do
    patch tag_url(@tag), params: { tag: { name: 'Updated tag name' } }, as: :json
    assert_redirected_to tag_url(@tag)
  end

  test 'should destroy tag' do
    @content_item.tags.delete(@tag)
    assert_difference('Tag.count', -1) do
      delete tag_url(@tag), as: :json
    end

    assert_redirected_to tags_url
  end
end
