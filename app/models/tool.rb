class Tool < ApplicationRecord
  validates :name, :language, presence: true
end
