class ProductsController < ApplicationController

  def index
    @products = Product.all
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
        format.html { redirect_to @product, notice: t('activerecord.attributes.products.created') }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: t('activerecord.attributes.products.updated') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: t('activerecord.attributes.products.destroyed') }
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