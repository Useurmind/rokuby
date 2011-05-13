require "ProjectManagement/cpp_project_configuration"
require "VisualStudio/vs_xml_file_utility"
require "general_utility"

module RakeBuilder
  # Types of binaries
  VS_CONFIGURATION_TYPE_APPLICATION = "Application"
  VS_CONFIGURATION_TYPE_SHARED = "DynamicLibrary"
  VS_CONFIGURATION_TYPE_STATIC = "StaticLibrary"
  
  # Binary extensions
  VS_CONFIGURATION_EXTENSION_APPLICATION = ".exe"
  VS_CONFIGURATION_EXTENSION_SHARED = ".dll"
  VS_CONFIGURATION_EXTENSION_STATIC = ".lib"

  # Config file variables
  VS_CONFIGURATION_SOLUTION_DIR = "$(SolutionDir)"
  VS_CONFIGURATION_INTERMEDIATE_DIR = "$(IntDir)"
  VS_CONFIGURATION_OUTPUT_DIR = "$(OutDir)"
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
  # [IntermediateDirectory] The directory for intermediate build results.
  #
  # Compile time attributes:
  # [WarningLevel] The warning level (default: 'Level3')
  # [Optimization] The optimization that should be performed (e.g. 'Disabled', 'MaxSpeed')
  # [AdditionalIncludeDirectories] An array with all include directories.
  # [PreprocessorDefinitions] An array with all präprozessor definitions.
  # [AssemblerOutput] Option to enable listings that should be generated about the compilation (e.g. 'NoListing').
  # [FunctionLevelLinking] Seems to be good for performance, e.g. release builds (true, false).
  # [IntrinsicFunctions] Seems to be good for performance, e.g. release builds (true, false).
  # [ProgramDataBaseFileName] The name of the pdb file that should hold debug information.
  # 
  # Link time attributes:
  # [GenerateDebugInformation] Should debug information be generated (true, false).
  # [AdditionalLibraryDirectories] Array of directories where libraries should be searched.
  # [AdditionalDependencies] Array of names of libraries that should be linked in.
  # [EnableCOMDATFolding] Seems to be good for performance, e.g. release builds (true, false).
  # [OptimizeReferences] Seems to be good for performance, e.g. release builds (true, false).
  class VsProjectConfiguration < CppProjectConfiguration
    include GeneralUtility
    include VsXmlFileUtility
    
    #attr_accessor :Name inherited from CppProjectConfiguration
    attr_accessor :Platform    
    attr_accessor :TargetName    
    attr_accessor :TargetExt
    attr_accessor :ConfigurationType
    
    attr_accessor :UseDebugLibraries
    attr_accessor :WholeProgramOptimization
    attr_accessor :CharacterSet
    attr_accessor :OutputDirectory
    attr_accessor :IntermediateDirectory

    attr_accessor :WarningLevel
    attr_accessor :Optimization
    attr_accessor :AdditionalIncludeDirectories
    attr_accessor :PreprocessorDefinitions
    attr_accessor :AssemblerOutput
    attr_accessor :FunctionLevelLinking
    attr_accessor :IntrinsicFunctions
    attr_accessor :ProgramDataBaseFileName

    attr_accessor :GenerateDebugInformation
    attr_accessor :AdditionalLibraryDirectories
    attr_accessor :AdditionalDependencies
    attr_accessor :EnableCOMDATFolding
    attr_accessor :OptimizeReferences

    def initialize
      super
      
      @Name = "Release"
      @Platform = "Win32"

      @TargetName = @Name
      @TargetExt = ".exe"
      @ConfigurationType = VS_CONFIGURATION_TYPE_APPLICATION
      @UseDebugLibraries = false
      @WholeProgramOptimization = true
      @CharacterSet = "MultiByte"
      @OutputDirectory = "$(SolutionDir)\\dist\\$(Configuration)\\"
      @IntermediateDirectory = "$(SolutionDir)\\build\\$(Configuration)\\"

      @WarningLevel = "Level3"
      @Optimization = "MaxSpeed"
      @AssemblerOutput = "NoListing"
      @FunctionLevelLinking = true
      @IntrinsicFunctions = true

      @GenerateDebugInformation = false
      @EnableCOMDATFolding = true
      @OptimizeReferences = true
      
      InitLists()
    end
    
    def InitLists
      @AdditionalIncludeDirectories = []
      @AdditionalLibraryDirectories = []
      @PreprocessorDefinitions = ["_WINDLL", "%(PreprocessorDefinitions)"]
      @AdditionalDependencies = ["%(AdditionalDependencies)"]
    end
    
    def InitializeFromParent(parent)
      InitCopy(parent)
      SyncWithParent()
    end
    
    def initialize_copy(original)
      super(original)
      
      @Name = Clone(original.Name)
      @Platform = Clone(original.Platform)

      @TargetName = Clone(original.TargetName)
      @TargetExt = Clone(original.TargetExt)
      @ConfigurationType = Clone(original.ConfigurationType)
      @UseDebugLibraries = Clone(original.UseDebugLibraries)
      @WholeProgramOptimization = Clone(original.WholeProgramOptimization)
      @CharacterSet = Clone(original.CharacterSet)
      @OutputDirectory = Clone(original.OutputDirectory)

      @WarningLevel = Clone(original.WarningLevel)
      @Optimization = Clone(original.Optimization)
      @AdditionalIncludeDirectories = Clone(original.AdditionalIncludeDirectories)
      @PreprocessorDefinitions = Clone(original.PreprocessorDefinitions)
      @AssemblerOutput = Clone(original.AssemblerOutput)
      @FunctionLevelLinking = Clone(original.FunctionLevelLinking)
      @IntrinsicFunctions = Clone(original.IntrinsicFunctions)

      @GenerateDebugInformation = Clone(original.GenerateDebugInformation)
      @AdditionalLibraryDirectories = Clone(original.AdditionalLibraryDirectories)
      @AdditionalDependencies = Clone(original.AdditionalDependencies)
      @EnableCOMDATFolding = Clone(original.EnableCOMDATFolding)
      @OptimizeReferences = Clone(original.OptimizeReferences)
    end

    def GetNamePlatformCombi
      return "#{@Name}|#{@Platform}"
    end

    def GetConfigurationCondition
      "'$(Configuration)|$(Platform)'=='#{GetNamePlatformCombi()}'"
    end
    
    def SyncWithParent()
      InitLists()
      
      @TargetName = @BinaryName

      #set binary type
      if(@BinaryType == :application)
        @ConfigurationType = VS_CONFIGURATION_TYPE_APPLICATION
        @TargetExt = VS_CONFIGURATION_EXTENSION_APPLICATION
      elsif(@BinaryType == :shared)
        @ConfigurationType = VS_CONFIGURATION_TYPE_SHARED
        @TargetExt = VS_CONFIGURATION_EXTENSION_SHARED
      else
        abort "Binary type #{@BinaryType} not supported"
      end

      if(@ProgramDataBaseFileName == nil)
        @ProgramDataBaseFileName = "#{VS_CONFIGURATION_OUTPUT_DIR}#{@BinaryName}.pdb"
      end
      @PreprocessorDefinitions.concat(Clone(@Defines))

      @AdditionalIncludeDirectories.concat(_GetVsIncludeDirectories())
      _SetVsLibraryAttributes()

      @OutputDirectory = JoinXmlPaths( [VS_CONFIGURATION_SOLUTION_DIR, "..", @BuildDirectory, "vs-#{VS_CONFIGURATION_CONFIGURATION_NAME}"] )
      @IntermediateDirectory = JoinXmlPaths( [VS_CONFIGURATION_SOLUTION_DIR, "..", @CompilesDirectory, "vs-#{VS_CONFIGURATION_CONFIGURATION_NAME}"] )
    end
    
    def _GetVsIncludeDirectories()
      includeTree = GetIncludeDirectoryTree()
      vsIncludeTree = []
      includeTree.each do |directory|
        vsIncludeDirectory = GetVsProjectRelativePath(GetProjectRelativePath(directory)) 

        vsIncludeTree.push(vsIncludeDirectory)
      end
      return vsIncludeTree
    end
    
    def _SetVsLibraryAttributes()
      libraryDirectories = []
      libraryNames = []
      libraryIncludePaths = []

      @Libraries.each do |libContainer|
        if(!libContainer.UsedInWindows())
          next
        end

        libraryNames.push(libContainer.GetFileName(:Windows))

        if(libContainer.GetLibraryPath(:Windows) != nil)
          libraryPath = GetVsProjectRelativePath(libContainer.GetLibraryPath(:Windows)) 
          if(libraryDirectories.index(libraryPath) == nil)
            libraryDirectories.push(libraryPath)
          end
        end

        libContainer.GetHeaderPaths(:Windows).each do |headerPath|
          relativePath =  GetVsProjectRelativePath(headerPath) 
          
          if(libraryIncludePaths.index(relativePath) == nil)
            libraryIncludePaths.push( relativePath )
          end
        end
      end

      @AdditionalIncludeDirectories.concat(libraryIncludePaths)
      @AdditionalDependencies.concat(libraryNames)
      @AdditionalLibraryDirectories.concat(libraryDirectories)
    end
  end
end
