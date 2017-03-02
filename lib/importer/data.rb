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

        product = Product.new()
        campaign = Campaign.new()
        product_images_url = []

        row.each do |cell|
          # Find db_column based on csv_column name
          db_column = @params[:product].find{|i| i[1] == cell[0]}.try(:first)
          product[db_column] = cell[1] if db_column.present?

          # If there is brand column in csv
          brand_db_column = @params[:brand].find{|i| i[1] == cell[0]}.try(:first)
          if @params[:brand].present? && brand_db_column.present?
            brand = Brand.find_or_create_by(name: cell[1])
            product[:brand_id] = brand.id
          end

          # If there is brand column in csv
          widget_db_column = @params[:widget].find{|i| i[1] == cell[0]}.try(:first)
          if @params[:widget].present? && brand_db_column.present?
            widget = Widget.find_or_create_by(name: cell[1])
            product[:widget_id] = widget.id
          end

          # If there is campaign column in csv
          campaign_db_column = @params[:campaign].find{|i| i[1] == cell[0]}.try(:first)
          if @params[:campaign].present? && campaign_db_column.present?
            campaign[campaign_db_column] = cell[1]
          end

          if (cell[0] == "image_urls")
            product_images_url = cell[1].split(",")
          end
        end

        # Check if there is already a campaign with same source id
        old_campaign = campaign[:source_id].present? ? Campaign.find_by(source_id: campaign[:source_id]) : nil
        if old_campaign.present?
          old_campaign.update(campaign.attributes.except("id", "created_at", "updated_at"))
          product[:campaign_id] = old_campaign.id
        else
          campaign.save if @params[:campaign].present?
          product[:campaign_id] = campaign.id
        end

        # Check if there is already a product with same source id
        old_product = product[:source_id].present? ? Product.find_by(source_id: product[:source_id]) : nil
        if old_product.present? && product[:source_id].present?
          old_product.update(product.attributes.except("id", "created_at", "updated_at"))
          if product_images_url.present?
            old_product.images.delete_all 
            old_product.images = product_images_url.map { |i| Image.new(url: i) }
            old_product.save
          end
        else
          product.images = product_images_url.map { |i| Image.new(url: i) } if product_images_url.present?
          product.save
        end
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

  end
end