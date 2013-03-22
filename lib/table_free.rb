module TableFree
  def initialize(options = {})
    options.each do |key, value|
      method_object = self.method("#{key}=".to_sym)
      method_object.call(value)
    end
  end

  def persisted?
    false
  end
end
