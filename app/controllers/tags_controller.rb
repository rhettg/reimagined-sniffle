# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :set_tag, only: %i[show edit update destroy]

  # GET /tags
  def index
    @tags = Tag.all
    render json: @tags
  end

  # GET /tags/new
  def new
    @tag = Tag.new
    render json: @tag
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to tags_url, notice: 'Tag was successfully created.'
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # GET /tags/:id
  def show
    render json: @tag
  end

  # GET /tags/:id/edit
  def edit
    render json: @tag
  end

  # PATCH/PUT /tags/:id
  def update
    if @tag.update(tag_params)
      redirect_to tags_url, notice: 'Tag was successfully updated.'
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/:id
  def destroy
    @tag.destroy
    redirect_to tags_url, notice: 'Tag was successfully destroyed.'
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
