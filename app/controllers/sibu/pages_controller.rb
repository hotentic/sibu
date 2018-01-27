require_dependency "sibu/application_controller"

module Sibu
  class PagesController < ApplicationController
    before_action :set_page, only: [:edit, :update, :destroy]
    skip_before_action Rails.application.config.sibu_auth_filter, only: [:show]

    def index
    end

    def show
      @site = Sibu::Site.find_by_domain(request.domain)
      if @site
        @page = @site.page(params[:path])
        view_template = @page ? 'show' : @site.not_found
      else
        view_template = Rails.application.config.sibu_not_found
      end
      render view_template, layout: 'sibu/site'
    end

    def new
      @page = Sibu::Page.new
    end

    def create
      @page = Sibu::Page.new(page_params)
      if @page.save
        redirect_to edit_page_url(@page), "La page a bien été créée."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la création de la page."
        render :new
      end
    end

    def edit
    end

    def update
      if @page.update(page_params)
        redirect_to edit_page_url(@page), notice: "La page a bien été mise à jour."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de la page."
        render :edit
      end
    end

    def destroy
    end

    private

    def set_page
      @page = Sibu::Page.find(params[:id])
      @site = @page.site if @page
    end

    def page_params
      params.require(:page).permit!
    end
  end
end
