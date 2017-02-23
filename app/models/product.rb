class Product < ApplicationRecord
  belongs_to :campaign, optional: true
  belongs_to :brand, optional: true
  belongs_to :widget, optional: true
  has_many :images

  validates_uniqueness_of :source_id
end
