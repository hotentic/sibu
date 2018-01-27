require_dependency "sibu/application_controller"

module Sibu
  class SitesController < ApplicationController
    before_action :set_site, only: [:show, :edit, :update, :destroy]
    skip_before_action Rails.application.config.sibu_auth_filter, only: [:show]

    def index
      @sites = Sibu::Site.where(user_id: send(Rails.application.config.sibu_current_user).id)
    end

    def show
      @page = @site.page('')
      render :show, layout: 'sibu/site'
    end

    def new
      @site = Sibu::Site.new(user_id: send(Rails.application.config.sibu_current_user).id)
    end

    def create
      @site = Sibu::Site.new(site_params)
      @site.init_data(:default)
      if @site.save
        redirect_to sites_url, notice: "Le site a bien été créé."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la création du site."
        render :new
      end
    end

    def edit
    end

    def update
      if @site.update(site_params)
        redirect_to sites_url, notice: "Le site a bien été mis à jour."
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
