module RakeBuilder
  # This class represents a visual studio project.
  # [ProjectFileSet] A file set representing the project file of the project.
  # [FilterFileSet] A file set representing the filter file of the project.
  class VsProject < Project
    attr_accessor :Guid
    attr_accessor :ProjectFilePath
    attr_accessor :FilterFilePath
    attr_accessor :Configurations
    
    attr_accessor :Private
    attr_accessor :ReferenceOutputAssembly
    attr_accessor :CopyLocalSatelliteAssemblies
    attr_accessor :LinkLibraryDependencies
    attr_accessor :UseLibraryDependencyInputs
    
    def initialize(valueMap=nil)
      
      @Guid = nil
      @ProjectFilePath = nil
      @FilterFilePath = nil
      @Configurations = []
      
      @Private = nil
      @ReferenceOutputAssembly = nil
      @CopyLocalSatelliteAssemblies = nil
      @LinkLibraryDependencies = nil
      @UseLibraryDependencyInputs = nil
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Guid = Clone(original.Guid)
      @ProjectFilePath = Clone(original.ProjectFilePath)
      @FilterFilePath = Clone(original.FilterFilePath)
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
    end
  end
end
