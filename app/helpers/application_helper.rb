module ApplicationHelper
  def new_drive_path
    new_drife_path
  end
  
  def edit_drive_path(id)
    edit_drife_path(id)
  end
  
  def drive_path
    drife_path
  end
  
  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, 
       params["#{field_name.to_s}(2i)"].to_i, 
       params["#{field_name.to_s}(3i)"].to_i)
  end
end
