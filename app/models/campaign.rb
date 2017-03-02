class Campaign < ApplicationRecord
  has_many :products
  
  COLUMNS_FOR_IMPORT = %w(name url source_id)

  validates_uniqueness_of :source_id, allow_blank: true
end
