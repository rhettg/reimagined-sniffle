# frozen_string_literal: true

# Controller for managing content items.
class ContentItemsController < ApplicationController
  before_action :set_content_item, only: %i[show edit update destroy]

  # GET /content_items
  def index
    @content_items = ContentItem.all
  end

  # GET /content_items/1
  def show; end

  # GET /content_items/new
  def new
    @content_item = ContentItem.new
  end

  # GET /content_items/1/edit
  def edit; end

  # POST /content_items
  def create
    @content_item = ContentItem.new(content_item_params)

    if @content_item.save
      @content_item.file.attach(params[:content_item][:file]) if params[:content_item][:file].present?
      render json: @content_item, status: :created, location: @content_item
    else
      render json: @content_item.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params)
      @content_item.file.attach(params[:content_item][:file]) if params[:content_item][:file].present?
      render json: @content_item, status: :ok, location: @content_item
    else
      render json: @content_item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /content_items/1
  def destroy
    if @content_item.destroy
      head :no_content
    else
      redirect_to content_items_url, alert: 'Cannot delete content item because it is referenced by other records.'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content_item
    @content_item = ContentItem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type, :title)
  end
end
