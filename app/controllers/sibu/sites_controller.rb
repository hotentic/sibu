require_dependency "sibu/application_controller"

module Sibu
  class SitesController < ApplicationController
    before_action :set_site, only: [:show, :edit, :update, :destroy]
    skip_before_action Rails.application.config.sibu[:auth_filter], only: [:show]

    def index
      @sites = Sibu::Site.where(user_id: send(Rails.application.config.sibu[:current_user]).id)
    end

    def show
      @page = @site.page('')
      redirect_to site_page_path(@site.id, @page.id)
    end

    def new
      @site = Sibu::Site.new(user_id: send(Rails.application.config.sibu[:current_user]).id)
    end

    def create
      @site = Sibu::Site.new(site_params)
      if @site.save_and_init
        redirect_to sites_url, notice: "Le site a bien été créé."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la création du site."
        render :new
      end
    end

    def edit
      @next_page = params[:next_page]
    end

    def update
      if @site.update(site_params)
        redirect_to (params[:next_page].blank? ? sites_url : params[:next_page]), notice: "Le site a bien été mis à jour."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement du site."
        render :edit
      end
    end

    def destroy
      @site.destroy
      redirect_to sites_url, notice: "Le site a bien été supprimé."
    end

    private

    def set_site
      @site = Sibu::Site.find(params[:id])
    end

    def site_params
      params.require(:site).permit!
    end
  end
end
