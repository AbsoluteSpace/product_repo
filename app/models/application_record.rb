class ApplicationRecord < ActiveRecord::Base
  require_relative "../../lib/messages/messages"
  self.abstract_class = true
end
