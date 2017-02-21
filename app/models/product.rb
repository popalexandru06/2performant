class Product < ApplicationRecord
  belongs_to :campaign
  belongs_to :brand
  belongs_to :widget
  has_many :images
end
