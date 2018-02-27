require_dependency "sibu/application_controller"

module Sibu
  class PagesController < ApplicationController
    before_action :set_page, only: [:edit, :update, :destroy, :edit_element, :update_element, :clone_element,
                                    :delete_element, :child_element, :new_section, :create_section, :delete_section]
    before_action :set_site, only: [:index, :new]
    before_action :set_edit_context, only: [:edit_element, :update_element, :clone_element, :delete_element,
                                            :child_element, :new_section, :create_section, :delete_section]
    skip_before_action Rails.application.config.sibu[:auth_filter], only: [:show]

    def index
      @pages = @site.pages.order(:created_at)
    end

    def show
      if params[:site_id].blank?
        @site = Sibu::Site.find_by_domain(request.domain)
        if @site
          @page = @site.page(params[:path])
          @links = @site.pages_path_by_id
          view_template = @page ? 'show' : @site.not_found
        else
          view_template = Rails.application.config.sibu[:not_found]
        end
      else
        @site = Sibu::Site.find(params[:site_id])
        @page = Sibu::Page.find(params[:id])
        @links = @site.pages_path_by_id
        view_template = 'show'
      end

      render view_template, layout: 'sibu/site'
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
    end

    def edit_content
      @page = Sibu::Page.find(params[:page_id])
      @site = Sibu::Site.includes(:pages).find(@page.site_id) if @page
      @links = @site.pages_path_by_id if @site
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
      @after = params[:after]
      @links = @site.pages_path_by_id
      @page.sections << {"id" => "sibu_template_free_text", "elements" => [{"id" => "paragraph0"}]}
      @page.sections << {"id" => "sibu_template_gallery",
                         "elements" => [{"id" => "slide0"}, {"id" => "slide1"}, {"id" => "slide2"}]}
      @page.sections << {"id" => "sibu_template_table", "elements" => [
          {"id" => "col0", "elements" => [{"id" => "row1"}, {"id" => "row2"}]},
          {"id" => "col1", "elements" => [{"id" => "row1"}, {"id" => "row2"}]},
      ]}
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

    def page_params
      params.require(:page).permit!
    end

    def element_params
      params.require(:element).permit!
    end

    def section_params
      params.require(:section).permit!
    end
  end
end
