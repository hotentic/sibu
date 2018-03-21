require_dependency "sibu/application_controller"

module Sibu
  class ImagesController < ApplicationController
    before_action :set_image, only: [:edit, :update, :destroy]
    before_action :set_edition_context, only: [:new, :create]

    def index
      @images = Sibu::Image.for_user(sibu_user)
    end

    def new
      @image = Sibu::Image.new(user_id: send(Rails.application.config.sibu[:current_user]).id)
    end

    def create
      @image = Sibu::Image.new(image_params)
      if @image.save
        if !@page_id.blank? && !@section_id.blank? && !@element_id.blank? && !@size.blank?
          p = Sibu::Page.find(@page_id)
          entity = @entity_type == 'site' ? p.site : p
          ids = (@section_id.split('|') + @element_id.split('|')).uniq[0...-1]
          elt = entity.update_element(*ids, {"id" => @img_id, "src" => @image.file_url(@size.to_sym), "alt" => @image.alt})
          if elt.nil?
            msg = {alert: "Une erreur s'est produite lors de la mise à jour de l'image."}
          else
            msg = {notice: "L'image a bien été mise à jour."}
          end
          redirect_to site_page_edit_content_path(@site.id, @page_id), msg
        else
          redirect_to images_url, notice: "L'image a bien été téléchargée."
        end
      else
        flash.now[:alert] = "Une erreur s'est produite lors du téléchargement de l'image."
        render :new
      end
    end

    def show
    end

    def edit
    end

    def update
      if @image.update(image_params)
        redirect_to images_url, notice: "L'image a bien été mise à jour."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de l'image."
        render :index
      end
    end

    def destroy
      @image.destroy
      redirect_to images_url, notice: "L'image a bien été supprimée."
    end

    private

    def set_image
      @image = Sibu::Image.find(params[:id])
    end

    def set_edition_context
      @page_id = params[:page_id]
      @entity_type = params[:entity_type]
      @section_id = params[:section_id]
      @element_id = params[:element_id]
      @img_id = params[:img_id]
      @size = params[:size]
    end

    def image_params
      params.require(:image).permit!
    end
  end
end
