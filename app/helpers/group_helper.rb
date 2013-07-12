module GroupHelper
  def row_error_class(num_errors)
    if num_errors > 3
      "error"
    elsif num_errors > 0
      "warning"
    else
      ""
    end
  end
end
