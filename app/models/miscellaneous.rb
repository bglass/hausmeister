module Miscellaneous

  # TrueClass
  def object_undefined?(name)
    !Object.const_defined?(name)
  end





end
