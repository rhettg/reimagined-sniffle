# frozen_string_literal: true

# Controller for managing content items.
class ContentItemsController < ApplicationController
  before_action :set_content_item, only: %i[show edit update destroy]

  # GET /content_items
  def index
    @content_items = ContentItem.all
    render json: @content_items.map { |item| item.as_json.merge(type: item.type, file_url: file_url(item), image_url: image_url(item)) }
  end

  # GET /content_items/1
  def show
    render json: @content_item.as_json.merge(
      type: @content_item.class.name,
      file_url: file_url(@content_item),
      image_url: image_url(@content_item)
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
    content_item_class = ContentItem.subclasses.find { |klass| klass.name == content_item_params[:type] }

    if content_item_class.nil?
      render json: { error: "Invalid content item type" }, status: :unprocessable_entity
      return
    end

    @content_item = content_item_class.new(content_item_params.except(:type, :file))

    if content_item_params[:file].present? && @content_item.respond_to?(:file)
      @content_item.file.attach(content_item_params[:file])
    end

    if @content_item.save
      render json: @content_item.as_json.merge(
        type: @content_item.class.name,
        file_url: file_url(@content_item),
        image_url: image_url(@content_item)
      ), status: :created, location: @content_item
    else
      render json: { errors: @content_item.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params.except(:type, :file))
      if content_item_params[:file].present? && @content_item.respond_to?(:file)
        @content_item.file.attach(content_item_params[:file])
      end

      render json: @content_item.as_json.merge(
        type: @content_item.class.name,
        file_url: file_url(@content_item),
        image_url: image_url(@content_item)
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
    @content_item = ContentItem.find_by(id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type, :title, :url, :content, :description, :thumbnail_url, :file)
  end

  def default_url_options
    { host: Rails.application.config.action_mailer.default_url_options&.fetch(:host, 'localhost:3000') }
  end

  def image_url(content_item)
    file_url(content_item)
  end

  def file_url(content_item)
    return nil unless content_item.respond_to?(:file) && content_item.file.attached?
    Rails.application.routes.url_helpers.rails_blob_url(content_item.file, only_path: false, host: default_url_options[:host])
  end
end
