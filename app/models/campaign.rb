class Campaign < ApplicationRecord
  has_many :products
  
  validates_uniqueness_of :source_id, allow_blank: true
end
