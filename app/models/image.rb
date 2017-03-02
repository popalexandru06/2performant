class Image < ApplicationRecord
  belongs_to :product

  COLUMNS_FOR_IMPORT = %w(urls)
end
