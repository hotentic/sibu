require_dependency "sibu/application_controller"

module Sibu
  class ImagesController < ApplicationController
    before_action :set_site, only: [:index, :new]

    def index
      @images = Sibu::Image.where(site_id: params[:site_id])
    end

    def new
      @image = Sibu::Image.new(site_id: @site.id)
    end

    def create
      @image = Sibu::Image.new(image_params)
      if @image.save
        redirect_to site_images_url(@image.site_id), notice: "L'image a bien été téléchargée."
      else
        flash.now[:alert] = "Une erreur s'est produite lors du téléchargement de l'image."
        render :new
      end
    end

    def show
    end

    def edit
    end

    def updateé
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
