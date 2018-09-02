require_dependency "sibu/application_controller"

module Sibu
  class PagesController < ApplicationController
    before_action :set_page, only: [:edit, :update, :destroy, :duplicate, :edit_element, :update_element, :clone_element,
                                    :delete_element, :child_element, :new_section, :create_section, :delete_section]
    before_action :set_site, only: [:index, :new]
    before_action :set_edit_context, only: [:edit_element, :update_element, :clone_element, :delete_element,
                                            :child_element, :new_section, :create_section, :delete_section]
    before_action :set_online, only: [:show, :edit]
    skip_before_action Rails.application.config.sibu[:auth_filter], only: [:show]

    def index
      @pages = @site.pages.order(:created_at)
    end

    def show
      return_code = :ok
      if params[:site_id].blank?
        @page = Sibu::Page.lookup(request.host, params[:path])
        if @page
          @query_path =  params[:path][@page.path.length + 1..-1] unless @page.path.blank?
          @query_params = show_params.except(:controller, :action, :path).to_h
          @site = @page.site
          @links = @site.pages_path_by_id
          view_template = 'show'
        else
          view_template = Rails.application.config.sibu[:not_found]
          return_code = :not_found
        end
      else
        @site = Sibu::Site.find(params[:site_id])
        @page = Sibu::Page.find(params[:id])
        @links = @site.pages_path_by_id
        view_template = 'show'
      end

      render view_template, layout: 'sibu/site', status: return_code
    end

    def new
      @page = Sibu::Page.new(site_id: @site.id)
    end

    def create
      @page = Sibu::Page.new(page_params)
      if @page.save_and_init
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
      site_id = @page.site_id
      if @page.destroy
        redirect_to site_pages_url(site_id), notice: "La page a bien été supprimée."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la suppression de la page."
        render :index
      end
    end

    def duplicate
      new_page = @page.deep_copy
      if new_page.save
        redirect_to site_pages_url(@page.site_id), notice: "La page a bien été copiée."
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la copie de la page."
        render :index
      end
    end

    def edit_content
      @page = Sibu::Page.find(params[:page_id])
      @site = Sibu::Site.includes(:pages).find(@page.site_id) if @page
      @links = @site.pages_path_by_id if @site
      @edit_section = params[:edit_section]
      render :edit_content, layout: 'sibu/edit_content'
    end

    def edit_element
      @content_type = params[:content_type]
      @links = @site.pages_path_by_id if @site
      @element = @entity.element(*@section_id.split('|'), *@element_id.split('|'))
      @repeat = params[:repeat]
      @size = params[:size].blank? ? :medium : params[:size].to_sym
      @children = params[:children]
    end

    def update_element
      ids = (@section_id.split('|') + @element_id.split('|')).uniq[0...-1]
      @updated = @entity.update_element(*ids, element_params)
      @refresh = params[:refresh]
    end

    def clone_element
      @cloned = @entity.clone_element(*@section_id.split('|'), *@element_id.split('|'))
    end

    def delete_element
      @deleted = @entity.delete_element(*@section_id.split('|'), *@element_id.split('|'))
    end

    def child_element
      @added = @entity.child_element(*@section_id.split('|'), *@element_id.split('|'))
    end

    def new_section
      page = Sibu::Page.find(params[:id])
      @page = Page.new(id: page.id, sections: [])
      @site = Sibu::Site.includes(:pages).find(page.site_id)
      @after = params[:after]
      @links = @site.pages_path_by_id

      @site.site_template.available_templates.each do |t|
        template_defaults = @site.site_template.templates ? (@site.site_template.templates[t["template"]] || {}) : {}
        @page.sections << template_defaults.merge(t).to_h
      end
    end

    def create_section
      @created = @entity.create_section(*@section_id.split('|'), params[:after], section_params)
    end

    def delete_section
      @deleted = @entity.delete_section(*@section_id.split('|'))
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

    def set_online
      @online = request.host != conf[:host]
    end

    def page_params
      params.require(:page).permit!
    end

    def element_params
      params.require(:element).permit!
    end

    def section_params
      params.require(:section).permit!
    end

    def show_params
      params.permit!
    end
  end
end
