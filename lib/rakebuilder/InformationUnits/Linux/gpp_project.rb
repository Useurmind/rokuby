module RakeBuilder
  class GppProject < Project    
    attr_accessor :Configurations
    
    def initialize(valueMap=nil)
      
      @Configurations = []
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Configurations = Clone(original.Configurations)
    end
    
    def GetConfiguration(platform)
      @Configurations.each() do |configuration|
        if(configuration.Platform <= platform)
          return configuration
        end
      end
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      configurations = valueMap[:Configurations] || valueMap[:confs]
      if(configurations)
        @Configurations = configurations
      end
    end
  end
end