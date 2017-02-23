class ProductsController < ApplicationController
  require 'csv'
  def index
    @products = Product.all.includes(:images, :campaign, :brand, :widget)
  end

  def show
  end

  def new
    @product = product.new
  end

  def edit
  end

  def create
    @product = product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: t('activerecord.attributes.product.created') }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: t('activerecord.attributes.product.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: t('activerecord.attributes.product.destroyed') }
    end
  end

  def map_fields
    file = File.open( session[:file_path])

    csv_header = get_csv_header(session[:file_path])

    content = file.read
    i = 0
    CSV.parse( content) do |row|
      i += 1
      next if (i == 1)
      # Create a new product 
      product = Product.new()
      campaign = Campaign.new()

      csv_header[:file_columns].each_with_index do |csv_column, index|
        # Find db_column based on csv_column name
        db_column = params[:product].find{|i| i[1] == csv_column}.try(:first)
        product[db_column] = row[index] if db_column.present?

        # If there is brand column in csv
        brand_db_column = params[:brand].find{|i| i[1] == csv_column}.try(:first)
        if params[:brand].present? && brand_db_column.present?
          brand = Brand.find_or_create_by(name: row[index])
          product[:brand_id] = brand.id
        end

        # If there is brand column in csv
        widget_db_column = params[:widget].find{|i| i[1] == csv_column}.try(:first)
        if params[:widget].present? && brand_db_column.present?
          widget = Widget.find_or_create_by(name: row[index])
          product[:widget_id] = widget.id
        end

        # If there is campaign column in csv
        campaign_db_column = params[:campaign].find{|i| i[1] == csv_column}.try(:first)
        if params[:campaign].present? && campaign_db_column.present?
          campaign[campaign_db_column] = row[index]
        end

        if (csv_column == "image_urls")
          
        end
        
      end
      
      # Check if there is already a campaign with same source id
      old_campaign = Campaign.find_by(source_id: campaign.source_id) 
      if old_campaign.present?
        old_campaign.update(campaign.attributes.except("id", "created_at", "updated_at"))
        product[:campaign_id] = old_campaign.id
      else
        campaign.save
        product[:campaign_id] = campaign.id
      end

      # Check if there is already a product with same source id
      old_product = Product.find_by(source_id: product[:source_id])
      if old_product.present?
        old_product.update(product.attributes.except("id", "created_at", "updated_at"))
      else
        product.save
      end
    end

    redirect_to products_path
  end

  def import
    file = params[:file]
    if file.present?
      file_name = file.original_filename
      file_path = "tmp/#{file_name}"
      session[:file_path] = file_path
      tmp_file = File.open( file_path, "wb")
      tmp_file.write( file.read )
      tmp_file.close
      response = get_csv_header(file_path)
      @file_columns = response[:file_columns]
      @select_options = @file_columns.map{|i| [i.humanize, i]}    
    else
      format.html { redirect_to products_url, notice: t('import.file_is_missing') }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:title, :aff_code, :price, :campaign_id, :widget_id, :short_message, :source_id, :brand_id, :is_active)
    end

    def get_csv_header file
      
      response = { success: true }
      begin
        file_columns = []

        file = File.open( file)
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