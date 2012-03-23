module RakeBuilder
  # This is an interface for all types of projects that should be reused in the build
  # process.
  # There can be several types of projects for the different types of outputs of a project.
  # As the projects are normally used in the context of the specific compiler only, they are
  # normally very specific to the type of compiler used.
  # In general they should represent the output binary and some additional meta values
  # that are needed to reuse it in other projects.
  # [Name] The name of the project.
  # [OutputBinaryFileSet] This is a file set representing the output binary of the project.
  # [Defines] The defines that are necessary to include this project successfully.
  # [Libraries] The libraries needed to run this project successfully.
  # [Dependencies] Other projects on which this projects depends.
  # [PassedDefines] A set of passed through defines which should be applied for certain platforms.
  class Project < InformationUnit
    attr_accessor :Name
    attr_accessor :IncludePaths
    attr_accessor :Defines
    attr_accessor :Libraries
    attr_accessor :Dependencies
    attr_accessor :PassedDefines
    
    def initialize(valueMap=nil)
      super(valueMap)
      
      @Name = ""
      @IncludePaths = []
      @Defines = []
      @Libraries = []
      @Dependencies = []
      @PassedDefines = []
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Name = Clone(original.Name)
      @IncludePaths = Clone(original.IncludePaths)
      @Defines = Clone(original.Defines)
      @Libraries = Clone(original.Libraries)
      @Dependencies = Clone(original.Dependencies)
      @PassedDefines = Clone(original.PassedDefines)
    end
    
    # Get the defines that this project wants other projects to use.
    def GetPassedDefines(platform)
      defines = []
      
      @PassedDefines.each() do |passedDefines|
        if(passedDefines.Platform <= platform)
          defines.concat(passedDefines.GatherDefines())
        end
      end
      
      return defines
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines(platform)
      defines = @Defines
      
      @Libraries.each() do |lib|
        libInstances = lib.GetInstances(platform)
        libInstances.each() do |libInst|
          defines.concat(libInst.GatherDefines())
        end
      end
      
      @Dependencies.each() do |dep|
        defines.concat(dep.GatherDefines(platform))
      end
      
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      name = valueMap[:Name] || valueMap[:name]
      if(name)
        @Name = name
      end
      
      includePaths = valueMap[:IncludePaths] || valueMap[:incPaths]
      if(includePaths)
        @IncludePaths.concat(includePaths)
      end
      
      task = valueMap[:Task] || valueMap[:task]
      if(task)
        @Task = task
      end
      
      defines = valueMap[:Defines] || valueMap[:defs]
      if(defines)
        @Defines.concat(defines)
      end
      
      libraries = valueMap[:Libraries] || valueMap[:libs]
      if(libraries)
        @Libraries.concat(libraries)
      end
      
      dependencies = valueMap[:Dependencies] || valueMap[:deps]
      if(dependencies)
        @Dependencies.concat(dependencies)
      end
      
      passedDefines = valueMap[:PassedDefines] || valueMap[:passDefs]
      if(passedDefines)
        @PassedDefines.concat(passedDefines)
      end
    end
  end
end
