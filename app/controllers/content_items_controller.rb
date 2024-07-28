# frozen_string_literal: true

# Controller for managing content items.
class ContentItemsController < ApplicationController
  before_action :set_content_item, only: %i[show edit update destroy]

  # GET /content_items
  def index
    @content_items = ContentItem.all
    render json: @content_items
  end

  # GET /content_items/1
  def show
    render json: @content_item.as_json.merge(type: @content_item.type, file_url: file_url_for(@content_item)), status: :ok
  end

  # GET /content_items/new
  def new
    @content_item = ContentItem.new
  end

  # GET /content_items/1/edit
  def edit; end

  # POST /content_items
  def create
    content_item_class = content_item_params[:type].constantize
    @content_item = content_item_class.new(content_item_params.except(:type, :file))

    if @content_item.save
      Rails.logger.debug "Content item created: #{@content_item.inspect}"
      if params[:content_item][:file].present?
        @content_item.file.attach(params[:content_item][:file])
        @content_item.save
        Rails.logger.debug "File attached: #{@content_item.file.attached?}"
        Rails.logger.debug "File blob: #{@content_item.file.blob.inspect}" if @content_item.file.attached?
      end
      Rails.logger.debug "File URL: #{file_url_for(@content_item)}"
      render json: @content_item.as_json.merge(
        type: @content_item.type,
        file_url: file_url_for(@content_item)
      ), status: :created, location: @content_item
    else
      render json: { errors: @content_item.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params.except(:file))
      if params[:content_item][:file].present?
        @content_item.file.attach(params[:content_item][:file])
        @content_item.save
      end
      render json: @content_item.as_json.merge(
        type: @content_item.type,
        file_url: file_url_for(@content_item)
      ), status: :ok, location: @content_item
    else
      render json: { errors: @content_item.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /content_items/1
  def destroy
    if @content_item.destroy
      head :no_content
    else
      render json: { errors: ['Cannot delete content item because it is referenced by other records.'] }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content_item
    @content_item = ContentItem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type, :title, :url, :content, :file)
  end

  # Generate file URL if file is attached
  def file_url_for(content_item)
    if content_item.file.attached?
      url = Rails.application.routes.url_helpers.rails_blob_path(content_item.file, only_path: true)
      Rails.logger.debug "Generated file URL: #{url}"
      url
    else
      Rails.logger.debug "No file attached to content item"
      nil
    end
  end
end
