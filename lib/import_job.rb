class ImportJob < Struct.new(:file_path, :params)
  def perform
    importer = Importer::Data.new(file_path, params)
    importer.import_products
  end
end