module ProductsHelper
  def generate_product_select_tag column, file_columns
    select_options = file_columns.map{|i| [i.humanize, i]} 
    case column
    when 'source_id'
      selected_option = 'product_id'
    when 'is_active'
      selected_option = 'product_active'
    else
      selected_option = column  
    end

    select_tag "product[#{column}]", options_for_select(select_options, file_columns.include?(selected_option) ? selected_option : nil ), class: "form-control", prompt: "Please Select"
  end

  def generate_select_tag column, file_columns, model
    select_options =  file_columns.map{|i| [i.humanize, i]} 
    if column == 'source_id'
      selected_option = "#{model}_id"
    elsif (column == "name" && model == "brand")
      selected_option = "brand"
    else
      selected_option = model + "_" + column  
    end
    select_tag "#{model}[#{column}]", options_for_select(select_options, file_columns.include?(selected_option) ? selected_option : nil ), class: "form-control", prompt: "Please Select"
  end

end
