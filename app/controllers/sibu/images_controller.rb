require_dependency "sibu/application_controller"

module Sibu
  class ImagesController < ApplicationController
    before_action :set_site, only: [:index, :new, :create, :edit]
    before_action :set_edition_context, only: [:new, :create]

    def index
      @images = Sibu::Image.where(site_id: params[:site_id])
    end

    def new
      @image = Sibu::Image.new(site_id: @site.id)
    end

    def create
      @image = Sibu::Image.new(image_params)
      if @image.save
        if @page_id && @section_id && @element_id && @size
          entity = @entity_type == 'site' ? @site : Sibu::Page.find(@page_id)
          ids = (@section_id.split('|') + @element_id.split('|')).uniq[0...-1]
          elt = entity.update_element(*ids, {"id" => @img_id, "src" => @image.file_url(@size.to_sym), "alt" => @image.alt})
          if elt.nil?
            msg = {alert: "Une erreur s'est produite lors de la mise à jour de l'image."}
          else
            msg = {notice: "L'image a bien été mise à jour."}
          end
          redirect_to site_page_edit_content_path(@site.id, @page_id), msg
        else
          redirect_to site_images_url(@image.site_id), notice: "L'image a bien été téléchargée."
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
    end

    def destroy
    end

    private

    def set_site
      @site = Sibu::Site.find(params[:site_id])
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
