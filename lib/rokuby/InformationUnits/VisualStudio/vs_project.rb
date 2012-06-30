module Rokuby
  # This class represents a visual studio project.
  # [ProjectFileSet] A file set representing the project file of the project.
  # [FilterFileSet] A file set representing the filter file of the project.
  class VsProject < Project
    attr_accessor :Guid
    attr_accessor :ProjectFilePath
    attr_accessor :FilterFilePath
    attr_accessor :Configurations
    
    attr_accessor :Usage
    
    def initialize(valueMap=nil)
      
      @Guid = nil
      @ProjectFilePath = nil
      @FilterFilePath = nil
      @Configurations = []
      
      @Usage = VsProjectUsage.new()
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Guid = Clone(original.Guid)
      @ProjectFilePath = Clone(original.ProjectFilePath)
      @FilterFilePath = Clone(original.FilterFilePath)
      @Configurations = Clone(original.Configurations)
      @Usage = Clone(original.Usage)
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
      
      guid = valueMap[:Guid] || valueMap[:guid]
      if(guid)
        @Guid = guid
      end
      
      projectFilePath = valueMap[:ProjectFilePath] || valueMap[:projFilePath]
      if(projectFilePath)
        @ProjectFilePath = projectFilePath
      end
      
      filterFilePath = valueMap[:FilterFilePath] || valueMap[:filterFilePath]
      if(filterFilePath)
        @FilterFilePath = filterFilePath
      end
      
      configurations = valueMap[:Configurations] || valueMap[:configurations]
      if(configurations)
        @Configurations.concat(configurations)
      end
      
      usage = valueMap[:Usage] || valueMap[:usage]
      if(usage)
        @Usage = usage
      end
    end
  end
end
