module Rokuby
  # This IU configures a g++ project.
  # [CompileOptions] The options that are added to commands for compiling source code files.
  # [LinkOptions] The options that are added to commands for linking.
  # [AdditionalPreLibraries] The libraries that should be linked before any other libraries.
  # [AdditionalPostLibraries] The libraries that should be linked after any other libraries.
  # [TargetName] The name of the binary that comes out of the build process.
  # [TargetExt] The extension of the binary that comes out of the build process.
  # [IncludePaths] The include paths necessary to compile the source code files.
  class GppProjectConfiguration < InformationConfiguration
    attr_accessor :CompileDirectory
    attr_accessor :OutputDirectory
    
    attr_accessor :CompileOptions
    attr_accessor :LinkOptions
    attr_accessor :AdditionalPreLibraries
    attr_accessor :AdditionalPostLibraries
    
    attr_accessor :TargetName
    attr_accessor :TargetExt
    
    attr_accessor :IncludePaths
    
    def initialize(valueMap=nil)
      
      @CompileDirectory = nil
      @OutputDirectory = nil
      @CompileOptions = []
      @LinkOptions = []
      @AdditionalPreLibraries = []
      @AdditionalPostLibraries = []
      
      @TargetName = nil
      @TargetExt = nil
      
      @IncludePaths = []
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @CompileDirectory = Clone(original.CompileDirectory)
      @OutputDirectory = Clone(original.OutputDirectory)
      @CompileOptions = Clone(original.CompileOptions)
      @LinkOptions = Clone(original.LinkOptions)
      @AdditionalPreLibraries = Clone(original.AdditionalPreLibraries)
      @AdditionalPostLibraries = Clone(original.AdditionalPostLibraries)
      
      @TargetName = Clone(original.TargetName)
      @TargetExt = Clone(original.TargetExt)
      
      @IncludePaths = Clone(original.IncludePaths)
    end
    
    def GetTargetFilePath
      return @OutputDirectory + ProjectPath.new(@TargetName + @TargetExt)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      compileDirectory = valueMap[:CompileDirectory] || valueMap[:compDir]
      if(compileDirectory)
        @CompileDirectory = compileDirectory
      end
      
      outputDirectory = valueMap[:OutputDirectory] || valueMap[:outDir]
      if(outputDirectory)
        @OutputDirectory = outputDirectory
      end
      
      compileOptions = valueMap[:CompileOptions] || valueMap[:compOpt]
      if(compileOptions)
        @CompileOptions = compileOptions
      end
      
      linkOptions = valueMap[:LinkOptions] || valueMap[:linkOpt]
      if(linkOptions)
        @LinkOptions = linkOptions
      end
      
      additionalPreLibraries = valueMap[:AdditionalPreLibraries] || valueMap[:addPreLibs]
      if(additionalPreLibraries)
        @AdditionalPreLibraries = additionalPreLibraries
      end
      
      additionalPostLibraries = valueMap[:AdditionalPostLibraries] || valueMap[:addPostLibs]
      if(additionalPostLibraries)
        @AdditionalPostLibraries = additionalPostLibraries
      end
      
      targetName = valueMap[:TargetName] || valueMap[:targetName]
      if(targetName)
        @TargetName = targetName
      end
      
      targetExt = valueMap[:TargetExt] || valueMap[:targetExt]
      if(targetExt)
        @TargetExt = targetExt
      end
      
      includePaths = valueMap[:IncludePaths] || valueMap[:inclPaths]
      if(includePaths)
        @IncludePaths = includePaths
      end
    end
  end
end
