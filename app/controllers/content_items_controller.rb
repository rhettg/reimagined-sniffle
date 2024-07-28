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
    Rails.logger.debug "Entering create action"
    Rails.logger.debug "Incoming parameters: #{params.inspect}"
    Rails.logger.debug "Content item params: #{content_item_params.inspect}"

    begin
      content_item_class = content_item_params[:type].constantize
      Rails.logger.debug "Content item class: #{content_item_class}"

      @content_item = content_item_class.new(content_item_params.except(:type, :file))
      Rails.logger.debug "New content item: #{@content_item.inspect}"

      ActiveRecord::Base.transaction do
        if @content_item.save
          Rails.logger.debug "Content item saved successfully: #{@content_item.inspect}"

          if content_item_params[:file].present?
            Rails.logger.debug "File present in params: #{content_item_params[:file].inspect}"
            attach_file
            Rails.logger.debug "File attached: #{@content_item.file.attached?}"
          else
            Rails.logger.debug "No file present in params"
          end

          file_url = file_url_for(@content_item)
          Rails.logger.debug "Generated file URL: #{file_url}"

          response_body = @content_item.as_json.merge(
            type: @content_item.type,
            file_url: file_url
          )
          Rails.logger.debug "Response body: #{response_body}"

          render json: response_body, status: :created, location: @content_item
          Rails.logger.debug "Response sent with status :created"
        else
          Rails.logger.debug "Content item save failed: #{@content_item.errors.full_messages}"
          render json: { errors: @content_item.errors }, status: :unprocessable_entity
          Rails.logger.debug "Response sent with status :unprocessable_entity"
        end
      end
    rescue NameError => e
      Rails.logger.error "NameError in create action: #{e.message}"
      render json: { error: "Invalid content item type" }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Validation error in create action: #{e.message}"
      render json: { errors: e.record.errors }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Error in create action: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "An error occurred while creating the content item" }, status: :internal_server_error
    ensure
      Rails.logger.debug "Exiting create action"
    end
  end

  private

  def attach_file
    Rails.logger.debug "File present in params: #{content_item_params[:file].inspect}"
    attachment_result = @content_item.file.attach(content_item_params[:file])
    Rails.logger.debug "File attachment result: #{attachment_result}"
    @content_item.save
    Rails.logger.debug "Content item saved after file attachment: #{@content_item.inspect}"
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
    permitted_params = params.require(:content_item).permit(:type, :title, :url, :content, :file)
    Rails.logger.debug "Permitted parameters: #{permitted_params.inspect}"
    permitted_params
  end

  # Generate file URL if file is attached
  def file_url_for(content_item)
    Rails.logger.debug "Entering file_url_for method for content_item: #{content_item.inspect}"
    Rails.logger.debug "File attached?: #{content_item.file.attached?}"
    return nil unless content_item.file.attached?

    begin
      host = determine_host
      Rails.logger.debug "Using host for URL generation: #{host}"

      url = Rails.application.routes.url_helpers.rails_blob_url(content_item.file, only_path: false, host: host)

      Rails.logger.debug "Generated URL components: #{URI.parse(url).to_h}"
      Rails.logger.debug "Generated file URL: #{url}"
      Rails.logger.debug "File attachment details: #{content_item.file.attachment.inspect}"
      url
    rescue StandardError => e
      Rails.logger.error "Error in file_url_for method: #{e.message}"
      Rails.logger.error "Full error details: #{e.full_message}"
      Rails.logger.error e.backtrace.join("\n")
      report_error(e)
      nil
    end
  end

  def determine_host
    default_url_options[:host] ||
      Rails.application.routes.default_url_options[:host] ||
      Rails.application.config.action_controller.default_url_options[:host] ||
      request.base_url ||
      'localhost:3000'
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

  def determine_host
    if Rails.env.production?
      ENV['APPLICATION_HOST'] || raise("APPLICATION_HOST environment variable is not set")
    else
      request.base_url || 'http://localhost:3000'
    end
  end
end
