require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @link = links(:links_one)
  end

  test "should get index" do
    get links_url, as: :json
    assert_response :success
  end

  test "should get new" do
    get new_link_url, as: :json
    assert_response :success
  end

  test "should create link" do
    assert_difference('Link.count') do
      post links_url, params: { link: { url: 'http://example.com', description: 'Example link' } }, as: :json
    end

    assert_redirected_to link_url(Link.last)
  end

  test "should show link" do
    get link_url(@link), as: :json
    assert_response :success
  end

  test "should get edit" do
    get edit_link_url(@link), as: :json
    assert_response :success
  end

  test "should update link" do
    patch link_url(@link), params: { link: { url: 'http://example.com', description: 'Updated description' } }, as: :json
    assert_redirected_to link_url(@link)
  end

  test "should destroy link" do
    assert_difference('Link.count', -1) do
      delete link_url(@link), as: :json
    end

    assert_redirected_to links_url
  end

  private

  def links_url
    "/links"
  end

  def new_link_url
    "/links/new"
  end

  def edit_link_url(link)
    "/links/#{link.id}/edit"
  end

  def link_url(link)
    "/links/#{link.id}"
  end
end
