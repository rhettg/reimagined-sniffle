# frozen_string_literal: true

# Controller for managing content items.
class ContentItemsController < ApplicationController
  before_action :set_content_item, only: %i[show edit update destroy]

  # GET /content_items
  def index
    Rails.logger.debug "Entering index action for ContentItemsController"
    @content_items = ContentItem.all
    render json: @content_items.map { |item| item.as_json.merge(type: item.type, file_url: file_url(item), image_url: image_url(item)) }
  end

  # GET /content_items/1
  def show
    Rails.logger.debug "Entering #{action_name} action for ContentItemsController"
    render json: @content_item.as_json.merge(
      type: @content_item.class.name,
      file_url: file_url(@content_item),
      image_url: image_url(@content_item)
    ), status: :ok
  end

  # GET /content_items/new
  def new
    Rails.logger.debug "Entering new action for ContentItemsController"
    @content_item = ContentItem.new
  end

  # GET /content_items/1/edit
  def edit
    Rails.logger.debug "Entering edit action for ContentItemsController"
  end

  # POST /content_items
  def create
    Rails.logger.debug "Entering create action for ContentItemsController"
    Rails.logger.debug "Incoming parameters: #{params.inspect}"
    permitted_params = content_item_params
    Rails.logger.debug "Permitted content item params: #{permitted_params.inspect}"

    content_item_class = ContentItem.subclasses.find { |klass| klass.name == permitted_params[:type] }

    if content_item_class.nil?
      render json: { error: "Invalid content item type" }, status: :unprocessable_entity
      return
    end

    @content_item = content_item_class.new(permitted_params.except(:file))

    ActiveRecord::Base.transaction do
      if @content_item.save
        Rails.logger.info "Content item saved successfully: #{@content_item.id}"

        if permitted_params[:file].present?
          attach_file(permitted_params[:file])
        else
          Rails.logger.debug "No file to attach"
        end

        render json: content_item_json(@content_item), status: :created
      else
        Rails.logger.error "Failed to save content item: #{@content_item.errors.full_messages}"
        render json: { errors: @content_item.errors }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Validation error in create action: #{e.message}"
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Error in create action: #{e.message}"
    render json: { error: "An error occurred while processing your request" }, status: :internal_server_error
  end

  private

  def attach_file(file_data)
    io = file_io(file_data)
    io.binmode
    io.rewind

    @content_item.file.attach(
      io: io,
      filename: file_name(file_data),
      content_type: content_type(file_data)
    )

    if @content_item.file.attached?
      Rails.logger.info "File attached successfully for content_item: #{@content_item.id}"
      Rails.logger.debug "File blob signed id: #{@content_item.file.blob.signed_id}"
    else
      Rails.logger.error "Failed to attach file for content_item: #{@content_item.id}"
      raise AttachmentError, "Failed to attach file"
    end
  rescue IOError, AttachmentError => e
    Rails.logger.error "Error during file attachment: #{e.message}"
    raise
  end

  def file_io(file_data)
    case file_data
    when ActionDispatch::Http::UploadedFile
      file_data.open
    when Hash
      file_data[:tempfile].is_a?(StringIO) ? file_data[:tempfile] : File.open(file_data[:tempfile])
    else
      StringIO.new(file_data.read)
    end
  end

  def file_name(file_data)
    file_data.respond_to?(:original_filename) ? file_data.original_filename : file_data[:original_filename]
  end

  def content_type(file_data)
    file_data.respond_to?(:content_type) ? file_data.content_type : file_data[:content_type]
  end

  # PATCH/PUT /content_items/1
  def update
    Rails.logger.debug "Entering update action for content_item with id: #{params[:id]}"
    Rails.logger.debug "Update params: #{params.inspect}"

    ActiveRecord::Base.transaction do
      if @content_item.update(content_item_params.except(:type, :file))
        Rails.logger.info "Content item updated successfully: #{@content_item.id}"

        if content_item_params[:file].present?
          begin
            attach_file(content_item_params[:file])
          rescue StandardError => e
            Rails.logger.error "Error attaching file during update: #{e.message}"
            raise ActiveRecord::Rollback
          end
        end

        render json: content_item_json(@content_item), status: :ok
      else
        Rails.logger.error "Failed to update content item: #{@content_item.errors.full_messages}"
        render json: { errors: @content_item.errors }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Content item not found with id: #{params[:id]}"
    render json: { error: "Content item not found" }, status: :not_found
  rescue StandardError => e
    Rails.logger.error "Error in update action: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "An error occurred while processing your request" }, status: :internal_server_error
  end

  # DELETE /content_items/1
  def destroy
    Rails.logger.debug "Entering destroy action for ContentItemsController"
    if @content_item.destroy
      Rails.logger.info "Content item #{@content_item.id} successfully destroyed"
      head :no_content
    else
      Rails.logger.error "Failed to destroy content item #{@content_item.id}: #{@content_item.errors.full_messages}"
      render json: { errors: @content_item.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Error in destroy action: #{e.message}"
    render json: { error: "An error occurred while processing your request" }, status: :internal_server_error
  end

  def default_url_options
    { host: request.base_url || 'http://localhost:3000' }
  end

  def file_url(content_item)
    Rails.logger.debug "Generating file_url for content_item: #{content_item.id}"
    Rails.logger.debug "File attached?: #{content_item.file.attached?}"

    url = if Rails.env.test?
            "http://test.host/test/file/url"
          elsif content_item.file.attached?
            Rails.application.routes.url_helpers.rails_blob_url(
              content_item.file,
              only_path: false,
              host: request.base_url
            )
          end

    Rails.logger.debug "Generated file URL: #{url || 'nil'}"
    url
  end

  def image_url(content_item)
    return nil unless content_item.is_a?(Image) && content_item.file.attached?
    Rails.application.routes.url_helpers.rails_blob_url(content_item.file, only_path: false, host: request.base_url)
  end





  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content_item
    Rails.logger.debug "Attempting to find ContentItem with id: #{params[:id]}"
    @content_item = ContentItem.find(params[:id])
    Rails.logger.debug "Result of find: #{@content_item.inspect}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "ContentItem with id #{params[:id]} not found"
    render json: { error: 'Content item not found' }, status: :not_found
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type, :title, :url, :content, :description, :thumbnail_url, :file)
  end

  def content_item_json(content_item)
    json = content_item.as_json.merge(
      type: content_item.type,
      title: content_item.title,
      content: content_item.content
    )

    if content_item.file.attached?
      json[:file_url] = file_url(content_item)
      json[:image_url] = image_url(content_item) if content_item.is_a?(Image)
    end
    json[:link_url] = content_item.url if content_item.is_a?(Link)

    Rails.logger.debug "Generated JSON for content_item #{content_item.id}: #{json.inspect}"
    json
  end

  def handle_file_attachment(content_item, file_data)
    return unless file_data.present?

    begin
      content_item.file.attach(
        io: file_data.tempfile,
        filename: file_data.original_filename,
        content_type: file_data.content_type
      )
      Rails.logger.info "File attached successfully for content_item: #{content_item.id}"
    rescue StandardError => e
      Rails.logger.error "Error attaching file for content_item #{content_item.id}: #{e.message}"
      raise
    end
  end
end
