class ProductsController < ApplicationController
  require 'csv'
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all.paginate(page: params[:page])
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

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
    if params[:file].present? && params[:file].original_filename.include?(".csv")
      create_tmp_file params[:file]

      response = Importer::Data.new(session[:file_path])
      @file_columns = response.get_csv_header
      @select_options = @file_columns.map{|i| [i.humanize, i]}    
    else
      respond_to do |format|
        format.html { redirect_to products_url, alert: (params[:file].present? ? t('import.choose_a_csv_file') : t('import.file_is_missing'))}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:title, :aff_code, :price, :campaign_id, :widget_id, :short_message, :source_id, :brand_id, :is_active)
    end

    def create_tmp_file file
      file_path = "tmp/#{file.original_filename}"
      tmp_file = File.open( file_path, "wb")
      tmp_file.write( file.read )
      tmp_file.close

      session[:file_path] = file_path
    end
end