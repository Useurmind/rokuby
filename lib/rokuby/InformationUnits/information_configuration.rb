module Rokuby
  # A base class for all configurations.
  # Configurations are associated using their platform values.
  # If the platform values are equal they belong together.
  # [Platform] The platform this configuration is meant for.
  # [Defines] A list of defines that should be used in this configuration.
  class InformationConfiguration < InformationUnit
    attr_accessor :Platform
    attr_accessor :Defines
    
    def initialize(valueMap)
      super(valueMap)
      
      @Platform = PlatformConfiguration.new()
      @Defines = []
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Platform = Clone(original.Platform)
      @Defines = Clone(original.Defines)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      return @Defines
    end
    
    def Extend(valueMap, callParent=true)
      #puts "in Extend of infoconf: #{valueMap}"
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      platform = valueMap[:Platform] || valueMap[:plat]
      if(platform)
        @Platform = platform
      end
      
      defines = valueMap[:Defines] || valueMap[:defs] || valueMap[:defines]
      if(defines)
        @Defines.concat(defines)
      end
    end
  end
end
