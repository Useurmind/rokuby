module RakeBuilder
  # This contains all the stuff that belongs to a single project.
  # [SourceUnits] The units that describe the source code of the project.
  # [Libraries] The libraries that belong to this project.
  class ProjectInstance < InformationInstance
    attr_accessor :SourceUnits
    attr_accessor :Libraries
    
    def initialize(valueMap=nil)
      super(valueMap)
      @SourceUnits = []
      @Libraries = []
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @SourceUnits = Clone(original.SourceUnits)
      @Libraries = Clone(original.Libraries)
    end
    
    def GetSourceDirectoryTree(excludeEmpty=false)
      dirs = []
      @SourceUnits.each() do |su|
        su.SourceFileSet.RootDirectories.each() do |dir|
          dirs.concat(GetDirectoryTree(dir, [], excludeEmpty))
        end
      end
      return dirs.uniq()
    end
    
    def GetIncludeDirectoryTree(excludeEmpty=false)
      dirs = []
      @SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |dir|
          dirs.concat(GetDirectoryTree(dir, [], excludeEmpty))
        end
      end
      return dirs.uniq()
    end
      
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      sourceUnits = valueMap[:SourceUnits] || valueMap[:srcUnits]
      if(sourceUnits)
        @SourceUnits = sourceUnits
      end
      
      libraries = valueMap[:Libraries] || valueMap[:libs]
      if(libraries)
        @Libraries = libraries
      end
    end
  end
end
