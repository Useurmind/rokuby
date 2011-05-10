
module RakeBuilder
  # Types of binaries
  VS_CONFIGURATION_TYPE_APPLICATION = "Application"
  VS_CONFIGURATION_TYPE_SHARED = "DynamicLibrary"
  
  # Binary extensions
  VS_CONFIGURATION_EXTENSION_APPLICATION = ".exe"
  VS_CONFIGURATION_EXTENSION_SHARED = ".dll"
  VS_CONFIGURATION_EXTENSION_STATIC = ".lib"

  # Config file variables
  VS_CONFIGURATION_SOLUTION_DIR = "$(SolutionDir)"
  VS_CONFIGURATION_CONFIGURATION_NAME = "$(Configuration)"

  # Represents a configuration for a project in Visual Studio
  # The default configuration is a release configuration.
  # General attributes:
  # [Name] The display name for the configuration.
  # [Platform] The platform to compile for (only Win32 possible)
  #
  # [TargetName] The name of the resulting binary.
  # [TargetExt] The extension for the resulting binary.
  # [ConfigurationType] The type of binary that is created (e.g. 'Application' or 'DynamicLibrary')
  # [UseDebugLibraries] Should debug libraries be used (true, false).
  # [WholeProgramOptimization] Should the program be optimized (true, false).
  # [CharacterSet] bla ('MultiByte')
  # [OutputDirectory] The directory for the build result.
  #
  # Compile time attributes:
  # [WarningLevel] The warning level (default: 'Level3')
  # [Optimization] The optimization that should be performed (e.g. 'Disabled', 'MaxSpeed')
  # [AdditionalIncludeDirectories] An array with all include directories.
  # [PreprocessorDefinitions] An array with all präprozessor definitions.
  # [AssemblerOutput] Option to enable listings that should be generated about the compilation (e.g. 'NoListing').
  # [FunctionLevelLinking] Seems to be good for performance, e.g. release builds (true, false).
  # [IntrinsicFunctions] Seems to be good for performance, e.g. release builds (true, false).
  # 
  # Link time attributes:
  # [GenerateDebugInformation] Should debug information be generated (true, false).
  # [AdditionalLibraryDirectories] Array of directories where libraries should be searched.
  # [AdditionalDependencies] Array of names of libraries that should be linked in.
  # [EnableCOMDATFolding] Seems to be good for performance, e.g. release builds (true, false).
  # [OptimizeReferences] Seems to be good for performance, e.g. release builds (true, false).
  class VsProjectConfiguration
    attr_accessor :Name
    attr_accessor :Platform
    attr_accessor :TargetName
    attr_accessor :TargetExt
    attr_accessor :ConfigurationType
    attr_accessor :UseDebugLibraries
    attr_accessor :WholeProgramOptimization
    attr_accessor :CharacterSet
    attr_accessor :OutputDirectory

    attr_accessor :WarningLevel
    attr_accessor :Optimization
    attr_accessor :AdditionalIncludeDirectories
    attr_accessor :PreprocessorDefinitions
    attr_accessor :AssemblerOutput
    attr_accessor :FunctionLevelLinking
    attr_accessor :IntrinsicFunctions

    attr_accessor :GenerateDebugInformation
    attr_accessor :AdditionalLibraryDirectories
    attr_accessor :AdditionalDependencies
    attr_accessor :EnableCOMDATFolding
    attr_accessor :OptimizeReferences

    def initialize
      @Name = "Release"
      @Platform = "Win32"

      @TargetName = @Name
      @TargetExt = ".exe"
      @ConfigurationType = VS_CONFIGURATION_TYPE_APPLICATION
      @UseDebugLibraries = false
      @WholeProgramOptimization = true
      @CharacterSet = "MultiByte"
      @OutputDirectory = "$(SolutionDir)\\build\\$(Configuration)\\"

      @WarningLevel = "Level3"
      @Optimization = "MaxSpeed"
      @AdditionalIncludeDirectories = []
      @PreprocessorDefinitions = ["_WINDLL", "%(PreprocessorDefinitions)"]
      @AssemblerOutput = "NoListing"
      @FunctionLevelLinking = true
      @IntrinsicFunctions = true

      @GenerateDebugInformation = false
      @AdditionalLibraryDirectories = []
      @AdditionalDependencies = ["%(AdditionalDependencies)"]
      @EnableCOMDATFolding = true
      @OptimizeReferences = true
    end

    def GetNamePlatformCombi
      return "#{@Name}|#{@Platform}"
    end

    def GetConfigurationCondition
      "'$(Configuration)|$(Platform)'=='#{GetNamePlatformCombi()}'"
    end
  end
end
