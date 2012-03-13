module RakeBuilder
  # This class represents a base class for all information units that are used to specify
  # where information can be found.
  # [Defines] Defines that can be inputn and that are propagated to the InformationInstance.
  class InformationSpecification < InformationUnit
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
