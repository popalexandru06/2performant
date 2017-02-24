class ProductsController < ApplicationController
  require 'csv'
  def index
    @products = Product.all.paginate(page: params[:page])
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

  def import
    Delayed::Job.enqueue(ImportJob.new(session[:file_path], params))

    redirect_to products_path, notice: t('import.in_progress')
  end

  def map_fields
    file = params[:file]
    if file.present?
      if file.original_filename.include? ".csv"
        file_name = file.original_filename
        file_path = "tmp/#{file_name}"

        tmp_file = File.open( file_path, "wb")
        tmp_file.write( file.read )
        tmp_file.close

        session[:file_path] = file_path

        response = Importer::Data.new(session[:file_path])
        response = response.get_csv_header

        @file_columns = response[:file_columns]
        @select_options = @file_columns.map{|i| [i.humanize, i]}    
      else
        respond_to do |format|
          format.html { redirect_to products_url, alert: t('import.choose_a_csv_file') }  
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to products_url, alert: t('import.file_is_missing') }
      end
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
end