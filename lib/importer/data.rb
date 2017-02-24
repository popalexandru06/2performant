require 'csv'

module Importer
  class Data

    def initialize file_path, params=nil, delete_file=true
      @file_name = file_path
      @params = params
      @delete_file = delete_file
    end

    def import_products
      file = File.open(@file_name)
      content = file.read
      i = 0
      CSV.parse( content) do |row|
        # Skip first line which contains the header
        i += 1
        next if (i == 1)
        # Initialize new product and new Campaign
        product = Product.new()
        campaign = Campaign.new()
        product_images_url = []

        get_csv_header[:file_columns].each_with_index do |csv_column, index|
          # Find db_column based on csv_column name
          db_column = @params[:product].find{|i| i[1] == csv_column}.try(:first)
          product[db_column] = row[index] if db_column.present?

          # If there is brand column in csv
          brand_db_column = @params[:brand].find{|i| i[1] == csv_column}.try(:first)
          if @params[:brand].present? && brand_db_column.present?
            brand = Brand.find_or_create_by(name: row[index])
            product[:brand_id] = brand.id
          end

          # If there is brand column in csv
          widget_db_column = @params[:widget].find{|i| i[1] == csv_column}.try(:first)
          if @params[:widget].present? && brand_db_column.present?
            widget = Widget.find_or_create_by(name: row[index])
            product[:widget_id] = widget.id
          end

          # If there is campaign column in csv
          campaign_db_column = @params[:campaign].find{|i| i[1] == csv_column}.try(:first)
          if @params[:campaign].present? && campaign_db_column.present?
            campaign[campaign_db_column] = row[index]
          end

          if (csv_column == "image_urls")
            product_images_url = row[index].split(",")
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
      response = { success: true }
      begin
        file_columns = []

        file = File.open(@file_name)
        content = file.read
        CSV.parse( content) do |row|
          row.each do |attribute|
            attribute_lowcase = attribute.downcase.gsub(" ","_")
            file_columns.push(attribute_lowcase)
          end
          break
        end
        response[:file_columns] = file_columns

      rescue Exception => e
        response = unless Rails.env.production?
          { success: false, line: 'unknown', message: "CSV parse error: " + e.message + "<br />" + e.backtrace.inspect }
        else
          { success: false, line: 'unknown', message: "Some error occured." }
        end
      end
      response
    end

  end
end