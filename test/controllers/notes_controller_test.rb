# frozen_string_literal: true

require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @note = notes(:notes_one)
  end

  test 'should get index' do
    get notes_url, as: :json
    assert_response :success
  end

  test 'should get new' do
    get new_note_url, as: :json
    assert_response :success
  end

  test 'should create note' do
    assert_difference('Note.count') do
      post notes_url, params: { note: { text: 'Example note content' } }, as: :json
    end

    assert_redirected_to note_url(Note.last)
  end

  test 'should show note' do
    get note_url(@note), as: :json
    assert_response :success
  end

  test 'should get edit' do
    get edit_note_url(@note), as: :json
    assert_response :success
  end

  test 'should update note' do
    patch note_url(@note), params: { note: { text: 'Updated note content' } }, as: :json
    assert_redirected_to note_url(@note)
  end

  test 'should destroy note' do
    assert_difference('Note.count', -1) do
      delete note_url(@note), as: :json
    end

    assert_redirected_to notes_url
  end

  private

  def notes_url
    '/notes'
  end

  def new_note_url
    '/notes/new'
  end

  def edit_note_url(note)
    "/notes/#{note.id}/edit"
  end

  def note_url(note)
    "/notes/#{note.id}"
  end
end
