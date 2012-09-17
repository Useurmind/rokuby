module Rokuby
  
  class GppProjectDescription < InformationUnit
    attr_accessor :Defines 
    
    def initialize(valueMap=nil)
      @Defines = []
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Defines = Clone(original.Defines)
    end
    
    def GatherDefines
      return @Defines
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
        @Defines |= defines
      end
    end
  end
end
