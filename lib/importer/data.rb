require 'csv'

module Importer
  class Data

    def initialize file_path, params=nil, delete_file=true
      @file_name = file_path
      @params = params
      @delete_file = delete_file
    end

    def import_products
      CSV.foreach(@file_name, headers: true) do |row|
        product = find_values_for_product row
        product[:widget_id] = find_and_create_widget row
        product[:brand_id] = find_and_create_brand row
        product[:campaign_id] = find_and_create_campaign row
        product.save        
        asign_images_to_product product, row   
      end
      File.delete(@file_name) if @delete_file
    end

    def get_csv_header 
      file_columns = []
      file = File.open(@file_name)
      row = CSV.read(file, headers: true).headers
      row.each do |attribute|
        file_columns.push(attribute.downcase.gsub(" ","_"))
      end
      file_columns
    end

    def find_values_for_product row
      product_params = {}
      Product::COLUMNS_FOR_IMPORT.each do |product_column|
        product_maped_column = @params[:product][product_column]
        product_params[product_column] = row[product_maped_column] if row[product_maped_column].present?
      end
      if row["product_id"].present?
        product = Product.find_or_initialize_by(source_id: row["product_id"])
        product.update_attributes(product_params)
      else
        product = Product.create(product_params)
      end
      product
    end

    def find_and_create_widget row
      widget_id = nil
      if @params[:widget].present?
        widget_maped_column = @params[:widget][:name]
        widget = Widget.find_or_create_by(name: row[widget_maped_column]) if row[widget_maped_column].present?
        widget_id = widget.id if widget.present?
      end
      widget_id
    end

    def find_and_create_brand row
      brand_id = nil
      if @params[:brand].present?
        brand_maped_column = @params[:brand][:name]
        brand = Brand.find_or_create_by(name: row[brand_maped_column]) if row[brand_maped_column].present?
        brand_id = brand.id if brand.present?
      end
      brand_id
    end

    def find_and_create_campaign row
      campaign_params = {}
      campaign_id = nil
      
      Campaign::COLUMNS_FOR_IMPORT.each do |campaign_column|
        campaign_maped_column = @params[:campaign][campaign_column]
        campaign_params[campaign_column] = row[campaign_maped_column] if row[campaign_maped_column].present?
      end
      if campaign_params.present?
        campaign = Campaign.find_or_initialize_by(source_id: row["campaign_id"])
        campaign.update_attributes(campaign_params)
        campaign_id = campaign.id
      end
      campaign_id
    end

    def asign_images_to_product product, row
      if @params[:image].present? && row[@params[:image][:urls]].present?
        product.images.delete_all
        product_images_url = row[@params[:image][:urls]].split(",")
        product.images = product_images_url.map { |i| Image.new(url: i) }
        product.save
      end
    end
  end
end