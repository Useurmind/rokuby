module Rokuby
  # This class holds additional values needed to describe a visual studio project
  # configuration.
  # The default configuration is for release builds.
  # Many values will not be set by default. If they are not set by the user they will
  # be set based on the values in the project information classes.
  # General attributes:
  # [PlatformName] The platform to compile for (based on the platform).
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
  class VsProjectConfiguration < InformationConfiguration
    include DirectoryUtility
    include GeneralUtility
    include Rake::DSL
    
    attr_accessor :PlatformName    
    attr_accessor :TargetName    
    attr_accessor :TargetExt
    attr_accessor :ConfigurationType
    attr_accessor :UseDebugLibraries
    attr_accessor :WholeProgramOptimization    
    attr_accessor :CharacterSet
    attr_accessor :OutputDirectory
    attr_accessor :IntermediateDirectory
    attr_accessor :RuntimeLibrary

    attr_accessor :WarningLevel
    attr_accessor :Optimization    
    attr_accessor :AdditionalIncludeDirectories
    attr_accessor :PreprocessorDefinitions
    attr_accessor :AssemblerOutput
    attr_accessor :FunctionLevelLinking
    attr_accessor :IntrinsicFunctions    
    attr_accessor :ProgramDataBaseFileName
    attr_accessor :ExceptionHandling
    attr_accessor :BufferSecurityCheck
    attr_accessor :DebugInformationFormat
    attr_accessor :InlineFunctionExpansion

    attr_accessor :GenerateDebugInformation
    attr_accessor :AdditionalLibraryDirectories
    attr_accessor :AdditionalDependencies
    attr_accessor :EnableCOMDATFolding
    attr_accessor :OptimizeReferences    
    attr_accessor :ModuleDefinitionFile
    
    attr_accessor :PostBuildCommand
    
    def Name
       return @Platform.Name
    end
    
    def NamePlatformCombi
      return "#{Name()}|#{@PlatformName}"
    end

    def ConfigurationCondition
      return "'$(Configuration)|$(Platform)'=='#{NamePlatformCombi()}'"
    end
    
    def initialize(valueMap=nil)      
      @PlatformName = nil

      @TargetName = nil
      @TargetExt = nil
      @ConfigurationType = nil
      @UseDebugLibraries = nil
      @WholeProgramOptimization = nil
      @CharacterSet = Vs::Configuration::CharacterSet::NOT_SET
      @OutputDirectory = nil
      @IntermediateDirectory = nil
      @RuntimeLibrary = Vs::Configuration::RuntimeLibrary::MULTITHREADED

      @WarningLevel = Vs::Configuration::WarningLevel::LEVEL3
      @Optimization = nil
      @AssemblerOutput = Vs::Configuration::AssemblerOutput::NO_LISTING
      @FunctionLevelLinking = nil
      @IntrinsicFunctions = nil
      @ProgramDataBaseFileName = nil
      @ExceptionHandling = Vs::Configuration::ExceptionHandling::SYNC
      @BufferSecurityCheck = true
      @DebugInformationFormat = Vs::Configuration::DebugInformationFormat::EDIT_AND_CONTINUE
      @InlineFunctionExpansion = Vs::Configuration::InlineFunctionExpansion::DEFAULT

      @GenerateDebugInformation = nil
      @EnableCOMDATFolding = nil
      @OptimizeReferences = nil
      @ModuleDefinitionFile = nil
      
      @AdditionalIncludeDirectories = []
      @AdditionalLibraryDirectories = []
      @PreprocessorDefinitions = ["%(PreprocessorDefinitions)"]
      @AdditionalDependencies = ["%(AdditionalDependencies)"]
      
      @PostBuildCommand = nil
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @PlatformName = Clone(original.PlatformName)

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
      
      @PostBuildCommand = Clone(original.PostBuildCommand)
    end
    
    def GetTargetFilePath
      return @OutputDirectory + ProjectPath.new(@TargetName + @TargetExt)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      return @Defines
    end
    
    def Extend(valueMap, callParent=true)
      #puts "in Extend of vsconf: #{valueMap}"
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      plat = valueMap[:PlatformName] || valueMap[:platformName]
      if(plat)
        @PlatformName = plat
      end

      targetName = valueMap[:TargetName] || valueMap[:targetName]
      if(targetName)
          @TargetName = targetName
      end
  
      targetExt = valueMap[:TargetExt] || valueMap[:targetExt]
      if(targetExt)
        @TargetExt = targetExt
      end
      
      configurationType = valueMap[:ConfigurationType] || valueMap[:configurationType]
      if(configurationType)
        @ConfigurationType = configurationType
      end
      
      useDebugLibraries = valueMap[:UseDebugLibraries] || valueMap[:useDebugLibraries]
      if(useDebugLibraries)
        @UseDebugLibraries = useDebugLibraries
      end
      
      wholeProgramOptimization = valueMap[:WholeProgramOptimization] || valueMap[:wholeProgramOptimization]
      if(wholeProgramOptimization)
        @WholeProgramOptimization = wholeProgramOptimization
      end
      
      characterSet = valueMap[:CharacterSet] || valueMap[:characterSet]
      if(characterSet)
        @CharacterSet = characterSet
      end
      
      outputDirectory = valueMap[:OutputDirectory] || valueMap[:outputDirectory]
      if(outputDirectory)
        @OutputDirectory = outputDirectory
      end
      
      intermediateDirectory = valueMap[:IntermediateDirectory] || valueMap[:intermediateDirectory]
      if(intermediateDirectory)
        @IntermediateDirectory = intermediateDirectory
      end
      
      runtimeLibrary = valueMap[:RuntimeLibrary] || valueMap[:runtimeLibrary]
      if(runtimeLibrary)
        @RuntimeLibrary = runtimeLibrary
      end

      warningLevel = valueMap[:WarningLevel] || valueMap[:warningLevel]
      if(warningLevel)
        @WarningLevel = warningLevel
      end
      
      optimization = valueMap[:Optimization] || valueMap[:optimization]
      if(optimization)
        @Optimization = optimization
      end
      
      assemblerOutput = valueMap[:AssemblerOutput] || valueMap[:assemblerOutput]
      if(assemblerOutput)
        @AssemblerOutput = assemblerOutput
      end
      
      functionLevelLinking = valueMap[:FunctionLevelLinking] || valueMap[:functionLevelLinking]
      if(functionLevelLinking)
        @FunctionLevelLinking = functionLevelLinking
      end
      
      intrinsicFunctions = valueMap[:IntrinsicFunctions] || valueMap[:intrinsicFunctions]
      if(intrinsicFunctions)
        @IntrinsicFunctions = intrinsicFunctions
      end
      
      programDataBaseFileName = valueMap[:ProgramDataBaseFileName] || valueMap[:programDataBaseFileName]
      if(programDataBaseFileName)
        @ProgramDataBaseFileName = programDataBaseFileName
      end
      
      exceptionHandling = valueMap[:ExceptionHandling] || valueMap[:exceptionHandling]
      if(exceptionHandling)
        @ExceptionHandling = exceptionHandling
      end
      
      bufferSecurityCheck = valueMap[:BufferSecurityCheck] || valueMap[:bufferSecurityCheck]
      if(bufferSecurityCheck)
        @BufferSecurityCheck = bufferSecurityCheck
      end
      
      debugInformationFormat = valueMap[:DebugInformationFormat] || valueMap[:debugInformationFormat]
      if(debugInformationFormat)
        @DebugInformationFormat = debugInformationFormat
      end
      
      inlineFunctionExpansion = valueMap[:InlineFunctionExpansion] || valueMap[:inlineFunctionExpansion]
      if(inlineFunctionExpansion)
        @InlineFunctionExpansion = inlineFunctionExpansion
      end

      generateDebugInformation = valueMap[:GenerateDebugInformation] || valueMap[:generateDebugInformation]
      if(generateDebugInformation)
        @GenerateDebugInformation = generateDebugInformation
      end
      
      enableCOMDATFolding = valueMap[:EnableCOMDATFolding] || valueMap[:enableCOMDATFolding]
      if(enableCOMDATFolding)
        @EnableCOMDATFolding = enableCOMDATFolding
      end
      
      optimizeReferences = valueMap[:OptimizeReferences] || valueMap[:optimizeReferences]
      if(optimizeReferences)
        @OptimizeReferences = optimizeReferences
      end
      
      moduleDefinitionFile = valueMap[:ModuleDefinitionFile] || valueMap[:moduleDefinitionFile]
      if(moduleDefinitionFile)
        @ModuleDefinitionFile = moduleDefinitionFile
      end
      
      additionalIncludeDirectories = valueMap[:AdditionalIncludeDirectories] || valueMap[:additionalIncludeDirectories]
      if(additionalIncludeDirectories)
        @AdditionalIncludeDirectories.concat(additionalIncludeDirectories)
      end
      
      additionalLibraryDirectories = valueMap[:AdditionalLibraryDirectories] || valueMap[:additionalLibraryDirectories]
      if(additionalLibraryDirectories)
        @AdditionalLibraryDirectories.concat(additionalLibraryDirectories)
      end
      
      preprocessorDefinitions = valueMap[:PreprocessorDefinitions] || valueMap[:preprocessorDefinitions] || valueMap[:defines] || valueMap[:defs]
      if(preprocessorDefinitions)
        @PreprocessorDefinitions.concat(preprocessorDefinitions)
      end
      
      additionalDependencies = valueMap[:AdditionalDependencies] || valueMap[:additionalDependencies]
      if(additionalDependencies)
        @AdditionalDependencies.concat(additionalDependencies)
      end
      
      postBuildCommand = valueMap[:PostBuildCommand] || valueMap[:postBuildCommand]
      if(postBuildCommand)
        @PostBuildCommand = postBuildCommand
      end
    end
  end
end
