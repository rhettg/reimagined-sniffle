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
    Rails.logger.debug "Raw params: #{params.inspect}"
    Rails.logger.debug "Content item params: #{content_item_params.inspect}"
    Rails.logger.debug "File param: #{params[:file].inspect}"

    content_item_class = content_item_params[:type].constantize
    @content_item = content_item_class.new(content_item_params.except(:type))

    ActiveRecord::Base.transaction do
      if @content_item.save
        if params[:file].present?
          @content_item.file.attach(params[:file])
          Rails.logger.debug "File attached: #{@content_item.file.attached?}"
        end
        file_url = image_url(@content_item)
        Rails.logger.debug "Content item: #{@content_item.inspect}"
        Rails.logger.debug "File attached?: #{@content_item.file.attached?}"
        Rails.logger.debug "File URL: #{file_url}"
        Rails.logger.debug "File blob: #{@content_item.file.blob.inspect}" if @content_item.file.attached?
        Rails.logger.debug "File URL before rendering: #{file_url}"
        render json: @content_item.as_json.merge(type: @content_item.class.name, file_url: file_url), status: :created, location: @content_item
      else
        Rails.logger.debug "Content item errors: #{@content_item.errors.full_messages}"
        render json: { errors: @content_item.errors }, status: :unprocessable_entity
      end
    end
  rescue NameError => e
    Rails.logger.error "Invalid content item type: #{e.message}"
    render json: { error: "Invalid content item type", details: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Error creating content item: #{e.message}"
    render json: { error: "An error occurred while creating the content item" }, status: :internal_server_error
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params.except(:type))
      if params[:file].present?
        @content_item.file.attach(params[:file])
      end

      file_url = file_url_for(@content_item)
      render json: @content_item.as_json.merge(type: @content_item.class.name, file_url: file_url), status: :ok
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
    @content_item = ContentItem.find_by(id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type, :title, :url, :content, :description, :thumbnail_url, :file)
  end

  def default_url_options
    { host: 'localhost:3000' } # Adjust this to match your test environment
  end

  def file_url_for(content_item)
    return nil unless content_item.file.attached?
    Rails.application.routes.url_helpers.rails_blob_url(content_item.file, only_path: false, host: default_url_options[:host])
  end

  def image_url(content_item)
    file_url_for(content_item)
  end
end
