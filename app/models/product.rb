class Product < ApplicationRecord
  self.per_page = 50

  COLUMNS_FOR_IMPORT = %w(title aff_code price old_price short_message description is_active source_id)

  belongs_to :campaign, optional: true
  belongs_to :brand, optional: true
  belongs_to :widget, optional: true
  has_many :images

  validates_uniqueness_of :source_id, allow_blank: true
  validates_numericality_of :price, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :old_price, :allow_nil => true, :greater_than_or_equal_to => 0
end
