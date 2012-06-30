module Rokuby
  # This class holds value that tells how a project is build.
  class ProjectConfiguration < InformationConfiguration
    
    def initialize(valueMap=nil)
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
    end
  end
end
