module RakeBuilder
  # This class represents a base class for all information units that are used to specify
  # where information can be found.
  # [Defines] Defines that can be inputn and that are propagated to the InformationInstance.
  class InformationSpecification < InformationUnit
    attr_accessor :Defines
    
    def initialize
      @Defines = []
    end
    
    def initialize_copy(original)
      @Defines = Clone(original.Defines)
    end
  end
end
