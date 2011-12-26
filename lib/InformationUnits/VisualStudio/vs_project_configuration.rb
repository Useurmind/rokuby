module RakeBuilder
  # This class holds additional values needed to describe a visual studio project
  # configuration.
  # The default configuration is for release builds.
  # Many values will not be set by default. If they are not set by the user they will
  # be set based on the values in the project information classes.
  # General attributes:
  # [Plat] The platform to compile for (based on the platform).
  # [TargetName] The name of the resulting binary (based on the project description name and the platform extension).
  # [TargetExt] The extension for the resulting binary (based on the project description binary type).
  # [ConfigurationType] The type of binary that is created (based on the project description binary type).
  # [UseDebugLibraries] Should debug libraries be used (bool) (based on the platform type).
  # [WholeProgramOptimization] Should the program be optimized (bool) (based on the platform type).
  # [CharacterSet] bla ('MultiByte', 'Unicode', 'NotSet').
  # [OutputDirectory] The directory for the build result (based on the project description build path).
  # [IntermediateDirectory] The directory for intermediate build results (based on the project description compiles path).
  #
  # Compile time attributes:
  # [WarningLevel] The warning level (default: 'Level3')
  # [Optimization] The optimization that should be performed (e.g. 'Disabled', 'MaxSpeed') (based on the platform type)
  # [AdditionalIncludeDirectories] An array with all include directories (based on the project instance).
  # [PreprocessorDefinitions] An array with all präprozessor definitions (basedon all gathered defines).
  # [AssemblerOutput] Option to enable listings that should be generated about the compilation (e.g. 'NoListing').
  # [FunctionLevelLinking] Seems to be good for performance, e.g. release builds (bool) (based on the platform type).
  # [IntrinsicFunctions] Seems to be good for performance, e.g. release builds (bool) (based on the platform type).
  # [ProgramDataBaseFileName] The name of the pdb file that should hold debug information.
  # [RuntimeLibrary] The windows libraries to be used with this project ('MultiThreaded', 'MultiThreadedDll', 'MultiThreadedDebug', 'MultiThreadedDebugDll').
  # [ExceptionHandling] Which type of exception handling should be applied (e.g. 'Async', 'false', default: 'Sync' )
  # [BufferSecurityCheck] bool, default: true.
  # [DebugInformationFormat] Format of the generated debug information (e.g. 'OldStyle', 'ProgramDatabase', default: 'EditAndContinue')
  # [InlineFunctionExpansion] How should functions be expanded inline (e.g. 'AnySuitable', 'Disabled', default: 'Default')
  # 
  # Link time attributes:
  # [GenerateDebugInformation] Should debug information be generated (bool) (based on the platform type). 
  # [AdditionalLibraryDirectories] Array of directories where libraries should be searched (based on project instance).
  # [AdditionalDependencies] Array of names of libraries that should be linked in (based on project instance).
  # [EnableCOMDATFolding] Seems to be good for performance, e.g. release builds (bool) (based on the platform type).
  # [OptimizeReferences] Seems to be good for performance, e.g. release builds (bool) (based on the platform type).
  # [ModuleDefinitionFile] The file that describes the exports of a library.
  class VSProjectConfiguration < InformationConfiguration
    include DirectoryUtility
    
    def Plat=(value)
      @Plat = value
    end
    
    def Plat()
      if(@Plat == nil)
        if(@Platform.Architecture == :x64)
          return VS::Configuration::Platform::X64
        elsif(@Platform.Architecture == :x86)
          return VS::Configuration::Platform::WIN32
        else
          raise "Unknown platform type in #{self.class.name}"
        end
      end
      
      return @Plat
    end
    
    attr_accessor :TargetName    
    attr_accessor :TargetExt
    attr_accessor :ConfigurationType
    
    def UseDebugLibraries=(val)
      @UseDebugLibraries = val
    end    
    def UseDebugLibraries
      if(@UseDebugLibraries == nil)
        return IsPlatformDebug()
      end      
      return @UseDebugLibraries 
    end
    
    def WholeProgramOptimization=(val)
      @WholeProgramOptimization = val
    end
    def WholeProgramOptimization
      @WholeProgramOptimization == nil ? !IsPlatformDebug() : @WholeProgramOptimization
    end
    
    attr_accessor :CharacterSet
    attr_accessor :OutputDirectory
    attr_accessor :IntermediateDirectory
    attr_accessor :RuntimeLibrary

    attr_accessor :WarningLevel
    
    def Optimization=(val)
      @Optimization = val
    end
    def Optimization
      if(@Optimization == nil)
        IsPlatformDebug() ? VS::ConfigurationType::Optimization::DISABLED : VS::ConfigurationType::Optimization::MAX_SPEED
      end
      return @Optimization
    end
    
    attr_accessor :AdditionalIncludeDirectories
    attr_accessor :PreprocessorDefinitions
    attr_accessor :AssemblerOutput
    
    def FunctionLevelLinking=(value)
      @FunctionLevelLinking = value
    end
    def FunctionLevelLinking
      @FunctionLevelLinking == nil ? !IsPlatformDebug() : @FunctionLevelLinking
    end
    
    def IntrinsicFunctions=(value)
      @IntrinsicFunctions = value
    end
    def IntrinsicFunctions
      @IntrinsicFunctions == nil ?  !IsPlatformDebug() : @IntrinsicFunctions
    end
    
    attr_accessor :ProgramDataBaseFileName
    attr_accessor :ExceptionHandling
    attr_accessor :BufferSecurityCheck
    attr_accessor :DebugInformationFormat
    attr_accessor :InlineFunctionExpansion

    def GenerateDebugInformation=(value)
      @GenerateDebugInformation = value
    end
    def GenerateDebugInformation
      @GenerateDebugInformation == nil ? IsPlatformDebug() : @GenerateDebugInformation
    end
    
    attr_accessor :AdditionalLibraryDirectories
    attr_accessor :AdditionalDependencies
    
    def EnableCOMDATFolding=(value)
      @EnableCOMDATFolding = value
    end
    def EnableCOMDATFolding
      @EnableCOMDATFolding == nil ? !IsPlatformDebug() : @EnableCOMDATFolding
    end
    
    def OptimizeReferences=(value)
      @OptimizeReferences = value
    end
    def OptimizeReferences
      @OptimizeReferences == nil ? !IsPlatformDebug() : @OptimizeReferences
    end
    
    attr_accessor :ModuleDefinitionFile
    
    attr_accessor :PostBuildCommand
    attr_accessor :AdditionalPostBuildAction
    
    def initialize
      super
      
      @Plat = nil

      @TargetName = nil
      @TargetExt = nil
      @ConfigurationType = VS::Configuration::ConfigurationType::APPLICATION
      @UseDebugLibraries = nil
      @WholeProgramOptimization = nil
      @CharacterSet = VS::Configuration::CharacterSet::NOT_SET
      @OutputDirectory = GenerateVSVariablePath("$(SolutionDir)/dist/$(Configuration)/")
      @IntermediateDirectory = GenerateVSVariablePath("$(SolutionDir)/build/$(Configuration)/")
      @RuntimeLibrary = VS::Configuration::RuntimeLibrary::MULTITHREADED

      @WarningLevel = VS::Configuration::WarningLevel::LEVEL3
      @Optimization = nil
      @AssemblerOutput = VS::Configuration::AssemblerOutput::NO_LISTING
      @FunctionLevelLinking = nil
      @IntrinsicFunctions = nil
      @ProgramDataBaseFileName = nil
      @ExceptionHandling = VS::Configuration::ExceptionHandling::SYNC
      @BufferSecurityCheck = true
      @DebugInformationFormat = VS::Configuration::DebugInformationFormat::EDIT_AND_CONTINUE
      @InlineFunctionExpansion = VS::Configuration::InlineFunctionExpansion::DEFAULT

      @GenerateDebugInformation = nil
      @EnableCOMDATFolding = nil
      @OptimizeReferences = nil
      @ModuleDefinitionFile = nil
      
      @AdditionalIncludeDirectories = []
      @AdditionalLibraryDirectories = []
      @PreprocessorDefinitions = ["%(PreprocessorDefinitions)"]
      @AdditionalDependencies = ["%(AdditionalDependencies)"]
    end
    
    def IsPlatformDebug
      return @Platform.Type == :Debug
    end
    
    def initialize_copy(original)
      super(original)
      
      @Plat = Clone(original.Plat)

      @TargetName = Clone(original.TargetName)
      @TargetExt = Clone(original.TargetExt)
      @ConfigurationType = Clone(original.ConfigurationType)
      @UseDebugLibraries = Clone(original.UseDebugLibraries)
      @WholeProgramOptimization = Clone(original.WholeProgramOptimization)
      @CharacterSet = Clone(original.CharacterSet)
      @OutputDirectory = Clone(original.OutputDirectory)
      @IntermediateDirectory = Clone(original.IntermediateDirectory)
      @RuntimeLibrary = Clone(original.RuntimeLibrary)

      @WarningLevel = Clone(original.WarningLevel)
      @Optimization = Clone(original.Optimization)
      @AssemblerOutput = Clone(original.AssemblerOutput)
      @FunctionLevelLinking = Clone(original.FunctionLevelLinking)
      @IntrinsicFunctions = Clone(original.IntrinsicFunctions)
      @ProgramDataBaseFileName = Clone(original.ProgramDataBaseFileName)
      @ExceptionHandling = Clone(original.ExceptionHandling)
      @BufferSecurityCheck = Clone(original.BufferSecurityCheck)
      @DebugInformationFormat = Clone(original.DebugInformationFormat)
      @InlineFunctionExpansion = Clone(original.InlineFunctionExpansion)

      @GenerateDebugInformation = Clone(original.GenerateDebugInformation)
      @EnableCOMDATFolding = Clone(original.EnableCOMDATFolding)
      @OptimizeReferences = Clone(original.OptimizeReferences)
      @ModuleDefinitionFile = Clone(original.ModuleDefinitionFile)
      
      @AdditionalIncludeDirectories = Clone(original.AdditionalIncludeDirectories)
      @AdditionalLibraryDirectories = Clone(original.AdditionalLibraryDirectories)
      @PreprocessorDefinitions = Clone(original.PreprocessorDefinitions)
      @AdditionalDependencies = Clone(original.AdditionalDependencies)
    end
  end
end
