module ProductsHelper
  def generate_product_select_tag product_column, file_columns
    select_options = file_columns.map{|i| [i.humanize, i]} 
    case product_column
    when 'source_id'
      selected_option = 'product_id'
    when 'is_active'
      selected_option = 'product_active'
    else
      selected_option = product_column  
    end

    select_tag "product[#{product_column}]", options_for_select(select_options, file_columns.include?(selected_option) ? selected_option : nil ), class: "form-control", prompt: "Please Select"
  end

end
