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
      file_url: @content_item.is_a?(Image) ? @content_item.file_url : nil
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
    Rails.logger.debug "File param: #{params.dig(:content_item, :file).inspect}"

    content_item_class = content_item_params[:type].constantize
    Rails.logger.debug "Content item class: #{content_item_class}"

    @content_item = content_item_class.new(content_item_params.except(:type, :file))
    Rails.logger.debug "New content item: #{@content_item.inspect}"

    ActiveRecord::Base.transaction do
      if @content_item.save
        Rails.logger.debug "Content item saved successfully: #{@content_item.inspect}"
        if @content_item.is_a?(Image) && params[:content_item][:file].present?
          attach_file_to_image(params[:content_item][:file])
        end

        response_data = @content_item.as_json.merge(type: @content_item.class.name)
        if @content_item.is_a?(Image)
          file_url = file_url_for(@content_item)
          Rails.logger.debug "Generated file_url for Image: #{file_url}"
          response_data[:file_url] = file_url
        end
        Rails.logger.debug "Final response_data: #{response_data.inspect}"

        render json: response_data, status: :created, location: @content_item
      else
        Rails.logger.error "Failed to save content item: #{@content_item.errors.full_messages}"
        render json: { errors: @content_item.errors }, status: :unprocessable_entity
      end
    end
  rescue NameError => e
    Rails.logger.error "Invalid content item type: #{e.message}"
    render json: { error: "Invalid content item type", details: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Error creating content item: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "An error occurred while creating the content item: #{e.message}" }, status: :internal_server_error
  end

  private

  def attach_file_to_image(file_param)
    if file_param.is_a?(ActionDispatch::Http::UploadedFile)
      @content_item.file.attach(file_param)
    elsif file_param.is_a?(Hash) && file_param[:tempfile].present?
      @content_item.file.attach(
        io: file_param[:tempfile],
        filename: file_param[:original_filename],
        content_type: file_param[:content_type]
      )
    else
      Rails.logger.error "Invalid file parameter type: #{file_param.class}"
      raise ArgumentError, "Invalid file parameter"
    end
    @content_item.save!
    Rails.logger.debug "File attached successfully: #{@content_item.file.attached?}"
    Rails.logger.debug "Attached file details: #{@content_item.file.blob.inspect}"
  rescue StandardError => e
    Rails.logger.error "Error attaching file: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise ActiveRecord::Rollback
  end

  private



  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params.except(:type, :file))
      if content_item_params[:file].present? && @content_item.is_a?(Image)
        @content_item.file.attach(content_item_params[:file])
      end

      render json: @content_item.as_json.merge(
        type: @content_item.type,
        file_url: @content_item.is_a?(Image) ? @content_item.file_url : nil
      ), status: :ok
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
    params.require(:content_item).permit(:type, :title, :url, :content, :description, :thumbnail_url, file: {})
  end

  def file_url_for(content_item)
    Rails.logger.debug "Generating file_url for content_item: #{content_item.inspect}"
    return nil unless content_item.is_a?(Image) && content_item.file.attached?

    url = Rails.application.routes.url_helpers.rails_blob_url(content_item.file, only_path: false, host: request.base_url)
    Rails.logger.debug "Generated file_url: #{url}"
    url
  end
end
