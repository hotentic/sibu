module Sibu
  class Page < ApplicationRecord
    include Sibu::SectionsConcern

    belongs_to :site, :class_name => 'Sibu::Site'

    store :metadata, accessors: [:title, :description], coder: JSON

    validates_presence_of :name, :site, :language, :template
  end
end
