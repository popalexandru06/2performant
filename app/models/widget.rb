class Widget < ApplicationRecord
  has_many :products

  COLUMNS_FOR_IMPORT = %w(name)
end
