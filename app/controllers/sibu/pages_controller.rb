require_dependency "sibu/application_controller"

module Sibu
  class PagesController < ApplicationController
    before_action :set_page, only: [:edit, :update, :destroy, :edit_element, :update_element, :edit_section]
    before_action :set_site, only: [:index, :new]
    before_action :set_edit_context, only: [:edit_element, :update_element]
    skip_before_action Rails.application.config.sibu[:auth_filter], only: [:show]

    def index
      @pages = @site.pages.order(:created_at)
    end

    def show
      if params[:site_id].blank?
        @site = Sibu::Site.find_by_domain(request.domain)
        if @site
          @page = @site.page(params[:path])
          @links = @site.internal_links
          view_template = @page ? 'show' : @site.not_found
        else
          view_template = Rails.application.config.sibu[:not_found]
        end
      else
        @site = Sibu::Site.find(params[:site_id])
        @page = Sibu::Page.find(params[:id])
        @links = @site.internal_links
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
        redirect_to site_pages_url(@page.site_id), notice: "La page a bien été créée."
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
      @site = Sibu::Site.includes(:pages).find(@page.site_id) if @page
      @links = @site.internal_links if @site
      render :edit_content, layout: 'sibu/edit_content'
    end

    def edit_element
      @content_type = params[:content_type]
    end

    def update_element
      @updated = @entity.update_element(@section_id, element_params)
    end

    def edit_section
    end

    def update_section
    end

    private

    def set_page
      @page = Sibu::Page.find(params[:id])
      @site = Sibu::Site.includes(:pages).find(@page.site_id) if @page
    end

    def set_site
      @site = Sibu::Site.find(params[:site_id])
    end

    def set_edit_context
      @entity_type = params[:entity]
      @section_id = params[:section_id]
      @element_id = params[:element_id]
      @entity = @entity_type == 'site' ? @site : @page
    end

    def page_params
      params.require(:page).permit!
    end

    def element_params
      params.require(:element).permit!
    end
  end
end
