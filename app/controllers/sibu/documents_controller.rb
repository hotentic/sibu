require_dependency "sibu/application_controller"

module Sibu
  class DocumentsController < ApplicationController
    def index
      @documents = Sibu::Document.for_user(sibu_user)
    end

    def new
      @document = Sibu::Document.new(user_id: send(Rails.application.config.sibu[:current_user]).id)
    end

    def create
      @document = Sibu::Document.new(document_params)
      if @document.save
        redirect_to documents_url, notice: "Le document a bien été téléchargé."
      else
        flash.now[:alert] = "Une erreur s'est produite lors du téléchargement du document."
        render :new
      end
    end

    def destroy
      @document = @document.find(params[:id])
      @document.destroy
      redirect_to documents_url, notice: "Le document a bien été supprimé."
    end

    private

    def document_params
      params.require(:document).permit!
    end
  end
end
