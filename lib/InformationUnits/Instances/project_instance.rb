module RakeBuilder
  # This contains all the stuff that belongs to a single project.
  # [SourceUnits] The units that describe the source code of the project.
  # [Libraries] The libraries that belong to this project.
  class ProjectInstance < InformationInstance
    attr_accessor :SourceUnits
    attr_accessor :Libraries
    
    def initialize
      super()
      @SourceUnits = []
      @Libraries = []
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
          dirs.concat(GetDirectoryTree(dir, [], excludeEmpty)  
        end
      end
      return dirs.uniq()
    end
    
    def GetIncludeDirectoryTree(excludeEmpty=false)
      dirs = []
      @SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |dir|
          dirs.concat(GetDirectoryTree(dir, [], excludeEmpty)  
        end
      end
      return dirs.uniq()
    end
  end
end
