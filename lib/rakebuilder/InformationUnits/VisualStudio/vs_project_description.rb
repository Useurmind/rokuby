module RakeBuilder
  # This class holds meta information about a project needed in visual studio.
  # [ProjectFilePath] The path of the project file.
  # [FilterFilePath] The path of the filter file.
  # [Guid] A unique UUID of the project in the form '{45CD...}'.
  # [RootNamespace] The root namespace of the project.
  class VsProjectDescription < InformationUnit
    attr_accessor :ProjectFilePath
    attr_accessor :FilterFilePath
    attr_accessor :Guid
    attr_accessor :RootNamespace
    attr_accessor :Defines
    
    def initialize(valueMap=nil)
      
      # filled by the project builder project preprocessor if not set
      @ProjectFilePath = nil
      @FilterFilePath = nil
      
      @Guid = GetUUID()
      @RootNamespace = ""
      
      @Defines = []
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @ProjectFilePath = Clone(original.ProjectFilePath)
      @FilterFilePath = Clone(original.FilterFilePath)
      @Guid = Clone(original.Guid)
      @RootNamespace = Clone(original.RootNamespace)
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
      
      projectFilePath = valueMap[:ProjectFilePath] || valueMap[:projFilePath]
      if(projectFilePath)
        @ProjectFilePath = projectFilePath
      end
      
      filterFilePath = valueMap[:FilterFilePath] || valueMap[:filterFilePath]
      if(filterFilePath)
        @FilterFilePath = filterFilePath
      end
      
      guid = valueMap[:Guid] || valueMap[:guid]
      if(guid)
        @Guid = guid
      end
      
      rootNamespace = valueMap[:RootNamespace] || valueMap[:rootNspc]
      if(rootNamespace)
        @RootNamespace = rootNamespace
      end
      
      defines = valueMap[:Defines] || valueMap[:defs]
      if(defines)
        @Defines = defines
      end
    end
  end
end
