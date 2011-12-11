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
    attr_accessor :ProjectPath
    attr_accessor :CompilesPath
    attr_accessor :BuildPath
    
    def initialize
      super
      
      @Name = ""
      @Version = "0.0"
      @BinaryName = ""
      @BinaryType = ""
      @ProjectPath = ProjectPath.new(".")
      @CompilesPath = ProjectPath.new("bin")
      @BuildPath = ProjectPath.new("build")
    end
    
    def initialize_copy(original)
      super(original)
      
      @Name = Clone(original.Name)
      @Version = Clone(original.Version)
      @BinaryName = Clone(original.BinaryName)
      @BinaryType = Clone(original.BinaryType)
      @ProjectPath = Clone(original.ProjectPath)
      @CompilesPath = Clone(original.CompilesPath)
      @BuildPath = Clone(original.BuildPath)
    end
  end
end
