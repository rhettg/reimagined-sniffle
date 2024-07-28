# frozen_string_literal: true

require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = images(:images_one)
  end

  test 'should get index' do
    get images_url, as: :json
    assert_response :success
  end

  test 'should get new' do
    get new_image_url, as: :json
    assert_response :success
  end

  test 'should create image' do
    assert_difference('Image.count') do
      post images_url, params: {
        image: {
          file: fixture_file_upload(Rails.root.join('test/fixtures/files/test_image.png'), 'image/png')
        }
      }, headers: { 'Content-Type': 'multipart/form-data' }
      assert_response :created
    end
  end

  test 'should show image' do
    get image_url(@image), as: :json
    assert_response :success
  end

  test 'should get edit' do
    get edit_image_url(@image), as: :json
    assert_response :success
  end

  test 'should update image' do
    patch image_url(@image), params: {
      image: {
        file: fixture_file_upload(Rails.root.join('test/fixtures/files/test_image.png'), 'image/png')
      }
    }, headers: { 'Content-Type': 'multipart/form-data' }
    assert_response :ok
  end

  test 'should destroy image' do
    assert_difference('Image.count', -1) do
      delete image_url(@image), as: :json
    end

    assert_response :no_content
  end

  private

  def images_url
    '/images'
  end

  def new_image_url
    '/images/new'
  end

  def edit_image_url(image)
    "/images/#{image.id}/edit"
  end

  def image_url(image)
    "/images/#{image.id}"
  end
end
