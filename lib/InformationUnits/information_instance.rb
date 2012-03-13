module RakeBuilder
  # This class represents a base class for all information units that are used to
  # transport the actual information that is used in the build process.
  # [Defines] Defines that come from the InformationSpecification.
  class InformationInstance < InformationUnit
    attr_accessor :Defines
    
    def initialize(valueMap)
      super(valueMap)
      @Defines = []
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @Defines = Clone(original.Defines)
    end
    
    # Get the defines from a InformationSpecification.
    def AddDefinesFrom(spec)
      @Defines.concat(Clone(spec.Defines))
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      defines = valueMap[:Defines] || valueMap[:defs]
      if(defines)
        @Defines.concat(defines)
      end
    end
  end
end
