require_dependency "sibu/application_controller"

module Sibu
  class ImagesController < ApplicationController
    before_action :set_site, only: [:index, :new, :create, :edit]

    def index
      @images = Sibu::Image.where(site_id: params[:site_id])
    end

    def new
      @image = Sibu::Image.new(site_id: @site.id)
      @page_id = params[:page_id]
    end

    def create
      @image = Sibu::Image.new(image_params)
      if @image.save
        redirect_to (params[:page_id].blank? ? site_images_url(@image.site_id) : site_page_edit_content_path(@site.id, params[:page_id])), notice: "L'image a bien été téléchargée."
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

    def image_params
      params.require(:image).permit!
    end
  end
end
