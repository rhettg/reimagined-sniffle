# frozen_string_literal: true

# Controller for managing content items.
class ContentItemsController < ApplicationController
  before_action :set_content_item, only: %i[show edit update destroy]

  # GET /content_items
  def index
    @content_items = ContentItem.all
    render json: @content_items.map { |item| item.as_json.merge(type: item.type) }
  end

  # GET /content_items/1
  def show
    render json: @content_item.as_json.merge(
      type: @content_item.class.name,
      file_url: file_url_for(@content_item)
    ), status: :ok
  end

  # GET /content_items/new
  def new
    @content_item = ContentItem.new
  end

  # GET /content_items/1/edit
  def edit; end

  # POST /content_items
  def create
    Rails.logger.debug "Params: #{params.inspect}"
    Rails.logger.debug "Content item params: #{content_item_params.inspect}"

    content_item_class = content_item_params[:type].constantize
    @content_item = content_item_class.new(content_item_params.except(:type, :file))

    ActiveRecord::Base.transaction do
      if @content_item.save
        if content_item_params[:file].present?
          @content_item.file.attach(content_item_params[:file])
        end
        response_data = build_response_data
        render json: response_data, status: :created, location: @content_item
      else
        render json: { errors: @content_item.errors }, status: :unprocessable_entity
      end
    end
  rescue NameError => e
    render json: { error: "Invalid content item type", details: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Error creating content item: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "An error occurred while creating the content item" }, status: :internal_server_error
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params.except(:type, :file))
      if content_item_params[:file].present? && @content_item.is_a?(Image)
        @content_item.file.attach(content_item_params[:file])
      end

      response_data = build_response_data
      render json: response_data, status: :ok
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

  def file_url_for(content_item)
    Rails.logger.debug "Checking file attachment for content_item: #{content_item.inspect}"
    return nil unless content_item.file.attached?
    Rails.logger.debug "File is attached"
    url = url_for(content_item.file)
    Rails.logger.debug "Generated URL: #{url}"
    url
  end

  private

  def build_response_data
    response_data = @content_item.as_json.merge(type: @content_item.class.name)
    file_url = file_url_for(@content_item)
    Rails.logger.debug "Generated file_url: #{file_url.inspect}"
    response_data[:file_url] = file_url if file_url
    response_data
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_content_item
    Rails.logger.debug "Attempting to find content item with id: #{params[:id]}"
    @content_item = ContentItem.find_by(id: params[:id])
    if @content_item
      Rails.logger.debug "Content item found: #{@content_item.inspect}"
    else
      Rails.logger.error "Content item not found for id: #{params[:id]}"
    end
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type, :title, :url, :content, :description, :thumbnail_url, :file)
  end
end
