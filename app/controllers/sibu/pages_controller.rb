require_dependency "sibu/application_controller"

module Sibu
  class PagesController < ApplicationController
    before_action :set_page, only: [:edit, :update, :destroy, :update_content]
    before_action :set_site, only: [:index, :new]
    skip_before_action Rails.application.config.sibu[:auth_filter], only: [:show]

    def index
      @pages = @site.pages.order(:created_at)
    end

    def show
      if params[:site_id].blank?
        @site = Sibu::Site.find_by_domain(request.domain)
        if @site
          @page = @site.page(params[:path])
          view_template = @page ? 'show' : @site.not_found
        else
          view_template = Rails.application.config.sibu[:not_found]
        end
      else
        @site = Sibu::Site.find(params[:site_id])
        @page = Sibu::Page.find(params[:id])
        view_template = 'show'
      end

      render view_template, layout: 'sibu/site'
    end

    def new
      @page = Sibu::Page.new(site_id: @site.id)
    end

    def create
      @page = Sibu::Page.new(page_params)
      if @page.save
        redirect_to site_pages_url(@page.site_id), "La page a bien été créée."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la création de la page."
        render :new
      end
    end

    def edit
    end

    def update
      if @page.update(page_params)
        redirect_to site_pages_url(@page.site_id), notice: "La page a bien été mise à jour."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de la page."
        render :edit
      end
    end

    def destroy
    end

    def edit_content
      @page = Sibu::Page.find(params[:page_id])
      @site = @page.site if @page
      render :edit_content, layout: 'sibu/edit_content'
    end

    def edit_element
    end

    def update_element
    end

    def edit_section
    end

    def update_section
    end

    private

    def set_page
      @page = Sibu::Page.find(params[:id])
      @site = @page.site if @page
    end

    def set_site
      @site = Sibu::Site.find(params[:site_id])
    end

    def page_params
      params.require(:page).permit!
    end
  end
end
