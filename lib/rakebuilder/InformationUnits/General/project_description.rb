module RakeBuilder
  # This class contains meta data for a project.
  # [Name] The name of the project in general.
  # [Version] The current version of the project.
  # [BinaryName] A basic name for the binary (this name will be modified by the configuration).
  # [BinaryType] The type of binary that is build by this project (see project_constants.rb).
  # [ProjectPath] The base directory where the project is build from.
  # [CompilesPath] The base directory where the compilation results of the project are stored.
  # [BuildPath] The base directory where the build results of the project are stored.
  class ProjectDescription < InformationUnit
    attr_accessor :Name
    attr_accessor :Version
    attr_accessor :BinaryName
    attr_accessor :BinaryType
    attr_accessor :CompilesPath
    attr_accessor :BuildPath
    attr_accessor :Defines
    
    def initialize(valueMap=nil)
      super(valueMap)
      
      @Name = ""
      @Version = "0.0"
      @BinaryName = ""
      @BinaryType = :Application
      @CompilesPath = ProjectPath.new(COMPILE_SUBDIR)
      @BuildPath = ProjectPath.new(BUILD_SUBDIR)
      @Defines = []
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Name = Clone(original.Name)
      @Version = Clone(original.Version)
      @BinaryName = Clone(original.BinaryName)
      @BinaryType = Clone(original.BinaryType)
      @CompilesPath = Clone(original.CompilesPath)
      @BuildPath = Clone(original.BuildPath)
      @Defines = Clone(original.Defines)
    end
    
    def GatherDefines()
      return @Defines
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
      
      version = valueMap[:Version] || valueMap[:ver]
      if(version)
        @Version = version
      end
      
      binaryName = valueMap[:BinaryName] || valueMap[:binName]
      if(binaryName)
        @BinaryName = binaryName
      end
      
      binaryType = valueMap[:BinaryType] || valueMap[:binType]
      if(binaryType)
        @BinaryType = binaryType
      end
      
      compilesPath = valueMap[:CompilesPath] || valueMap[:compPath]
      if(compilesPath)
        @CompilesPath = compilesPath
      end
      
      buildPath = valueMap[:BuildPath] || valueMap[:buildPath]
      if(buildPath)
        @BuildPath = buildPath
      end
      
      defines = valueMap[:Defines] || valueMap[:defs]
      if(defines)
        @Defines = defines 
      end
    end
  end
end
