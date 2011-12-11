module RakeBuilder
  # This class represents a base class for all information units that are used to
  # transport the actual information that is used in the build process.
  # [Defines] Defines that come from the InformationSpecification.
  class InformationInstance < InformationUnit
    attr_accessor :Defines
    
    def initialize
      @Defines = []
    end
    
    def initialize_copy(original)
      @Defines = Clone(original.Defines)
    end
    
    # Get the defines from a InformationSpecification.
    def AddDefinesFrom(spec)
      @Defines.concat(Clone(spec.Defines))
    end
  end
end
