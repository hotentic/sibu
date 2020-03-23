require_dependency "sibu/application_controller"

module Sibu
  class SitesController < ApplicationController
    before_action :set_site, only: [:show, :edit, :update, :destroy, :duplicate]
    skip_before_action Rails.application.config.sibu[:auth_filter], only: [:show]

    def index
      @sites = Sibu::Site.for_user(sibu_user).order(:name, :version)
    end

    def show
      @page = @site.page('')
      redirect_to site_page_path(@site.id, @page.id)
    end

    def new
      @site = Sibu::Site.new(user_id: sibu_user.id, version: Sibu::Site::DEFAULT_VERSION)
    end

    def create
      @site = Sibu::Site.new(site_params)
      if @site.save_and_init
        generate_styles(@site) if conf[:custom_styles]
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
        if conf[:custom_styles] && @site.previous_changes.has_key?(:custom_data)
          generate_styles(@site)
        end
        if @site.previous_changes.has_key?(:version)
          @site.update_paths
        end
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

    def duplicate
      new_site = @site.deep_copy
      if new_site.save
        if conf[:custom_styles]
          generate_styles(@site)
          generate_styles(new_site)
        end
        redirect_to sites_url, notice: "Le site a bien été copié."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la copie du site."
        render :index
      end
    end

    private

    def set_site
      @site = Sibu::Site.find(params[:id])
    end

    def site_params
      params.require(:site).permit!
    end

    def generate_styles(site)
      ds = Sibu::DynamicStyle.new(site.id)
      ds.compile
    end
  end
end
