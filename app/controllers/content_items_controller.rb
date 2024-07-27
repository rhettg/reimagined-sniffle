class ContentItemsController < ApplicationController
  before_action :set_content_item, only: %i[show edit update destroy]

  # GET /content_items
  def index
    @content_items = ContentItem.all
  end

  # GET /content_items/1
  def show
  end

  # GET /content_items/new
  def new
    @content_item = ContentItem.new
  end

  # GET /content_items/1/edit
  def edit
  end

  # POST /content_items
  def create
    @content_item = ContentItem.new(content_item_params)

    if @content_item.save
      redirect_to @content_item, notice: 'Content item was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /content_items/1
  def update
    if @content_item.update(content_item_params)
      redirect_to @content_item, notice: 'Content item was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /content_items/1
  def destroy
    @content_item.destroy
    redirect_to content_items_url, notice: 'Content item was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content_item
    @content_item = ContentItem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def content_item_params
    params.require(:content_item).permit(:type)
  end
end
