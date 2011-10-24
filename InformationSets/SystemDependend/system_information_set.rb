module RakeBuilder
  # System information sets are basic units of information flowing through the build process.
  # They are different from common information by the fact that they strongly depend on the
  # system setup an need to be filled with system specific information.
  # They are initialized with some values that are defined as input.
  # After calling fill the information set will be initialized with additional information
  # (normally based on the input values).
  class SystemInformationSet
    # Fill the information set with information based on the input values.
    def Fill
      raise "Fill not implemented in InformationSet"
    end
  end  
end