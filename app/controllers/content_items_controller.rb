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
    render json: @content_item, status: :ok
  end

  # GET /content_items/new
  def new
    @content_item = ContentItem.new
  end

  # GET /content_items/1/edit
  def edit; end

  # POST /content_items
  def create
    Rails.logger.debug "Entering create action"
    Rails.logger.debug "Incoming parameters: #{params.inspect}"
    Rails.logger.debug "Content item params: #{content_item_params.inspect}"

    content_item_class = content_item_params[:type].constantize
    Rails.logger.debug "Content item class: #{content_item_class}"

    @content_item = content_item_class.new(content_item_params.except(:type))
    Rails.logger.debug "New content item: #{@content_item.inspect}"

    if @content_item.file.attached?
      Rails.logger.debug "File attached: #{@content_item.file.attached?}"
      Rails.logger.debug "Attached file details: #{@content_item.file.blob.inspect}"
    end

    if @content_item.save
      handle_successful_save
    else
      handle_failed_save
    end
  rescue NameError => e
    handle_name_error(e)
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e)
  rescue StandardError => e
    handle_standard_error(e)
  ensure
    Rails.logger.debug "Exiting create action"
    Rails.logger.debug "Final content item state: #{@content_item.inspect}"
  end

  private



  def handle_successful_save
    Rails.logger.debug "Content item saved successfully: #{@content_item.inspect}"
    file_url = file_url_for(@content_item)
    Rails.logger.debug "Generated file URL: #{file_url}"
    response_body = @content_item.as_json.merge(type: @content_item.type, file_url: file_url)
    Rails.logger.debug "Response body: #{response_body.inspect}"
    render json: response_body, status: :created, location: @content_item
    Rails.logger.debug "Response sent with status :created"
  end

  def handle_failed_save
    Rails.logger.debug "Content item save failed: #{@content_item.errors.full_messages}"
    render json: { errors: @content_item.errors }, status: :unprocessable_entity
  end

  def handle_name_error(error)
    Rails.logger.error "NameError in create action: #{error.message}"
    render json: { error: "Invalid content item type", details: error.message }, status: :unprocessable_entity
  end

  def handle_record_invalid(error)
    Rails.logger.error "Validation error in create action: #{error.message}"
    render json: { errors: error.record.errors }, status: :unprocessable_entity
  end

  def handle_standard_error(error)
    Rails.logger.error "Error in create action: #{error.message}"
    render json: { error: "An error occurred while creating the content item" }, status: :internal_server_error
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params.except(:file))
      if content_item_params[:file].present?
        @content_item.file.attach(content_item_params[:file])
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

  # Generate file URL if file is attached
  def file_url_for(content_item)
    Rails.logger.debug "Calling file_url_for with content_item: #{content_item.inspect}"
    Rails.logger.debug "File attached?: #{content_item.file.attached?}"
    return nil unless content_item.file.attached?

    begin
      host = determine_host
      Rails.logger.debug "Using host for URL generation: #{host}"

      if content_item.file.is_a?(ActiveStorage::Attached::One)
        url = Rails.application.routes.url_helpers.rails_blob_url(content_item.file, host: host)
      elsif content_item.file.is_a?(ActiveStorage::Attached::Many)
        url = content_item.file.map { |file| Rails.application.routes.url_helpers.rails_blob_url(file, host: host) }
      else
        raise ArgumentError, "Unexpected file attachment type: #{content_item.file.class}"
      end

      Rails.logger.debug "Generated file URL(s): #{url}"
      url
    rescue StandardError => e
      Rails.logger.error "Error in file_url_for method: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      report_error(e)
      nil
    end
  end

  public

  def image_url(content_item)
    Rails.logger.debug "Entering image_url method for content_item: #{content_item.inspect}"
    result = file_url_for(content_item)
    Rails.logger.debug "Exiting image_url method. Result: #{result}"
    result
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
    params.require(:content_item).permit(:type, :title, :url, :content, :file, :description, :thumbnail_url)
  end

  def determine_host
    if Rails.env.production?
      ENV['APPLICATION_HOST'] || raise("APPLICATION_HOST environment variable is not set")
    elsif Rails.env.test?
      'http://localhost:3000'
    else
      request.base_url || 'http://localhost:3000'
    end
  end

  def report_error(error)
    # Implement error reporting logic here (e.g., sending to an error tracking service)
    Rails.logger.error "Error reported: #{error.message}"
  end

  def default_url_options
    host = determine_host
    Rails.logger.debug "Using host for URL generation: #{host}"
    { host: host }
  end

  # This method has been moved up and combined with the previous definition
  # def determine_host
  #   if Rails.env.production?
  #     ENV['APPLICATION_HOST'] || raise("APPLICATION_HOST environment variable is not set")
  #   elsif Rails.env.test?
  #     'http://localhost:3000'
  #   else
  #     request.base_url || 'http://localhost:3000'
  #   end
  # end

  # This method has been moved up and combined with the previous definition
  # def default_url_options
  #   { host: determine_host }
  # end
end
