require "directory_utility"
require "general_utility"


module RakeBuilder
  
  
  # This is a configuration for a C++ project.
  # It is independent of any type of build system and just includes the information
  # about the ingredients of the project.
  # [Name] The name of the configuration (default: "default").
  # [SourceIncludePatterns] Some RegExps that define the sources to include in the project.
  # [SourceExcludePatterns] Some RegExps which define the sources that should definitely not be included in the project.
  # [HeaderIncludePatterns] Some RegExps that define the headers to include in the project.
  # [HeaderExcludePatterns] Some RegExps which define the headers that should definitely not be included in the project.
  # [ProjectDirectory] The absolute path where the project is located.
  # [SourceDirectories] The directories in the ProjectDirectory for the source files.
  # [HeaderDirectories] The directories in the ProjectDirectory for the header files.
  # [CompilesDirectory] The directory in the ProjectDirectory for the compiled sources (defaults to 'bin').
  # [BuildDirectory] The directory in the ProjectDirectory for result of the build (defaults to 'build').
  # [StaticLibraries] Names of the static libraries to link in (e.g. "x264" for "libx264.a")
  # [DynamicLibraries] Names of the dynamic libraries to link in (e.g. "x264" for "libx264.so")
  # [Defines] Defines that should be set for the project.
  # [PrecompiledHeader] The file that can be used as a precompiled header (visual studio)
  # [BinaryName] The name of the binary that is created.
  # [BinaryType] The type of the binary to create (:shared, :static, :application, default: :application)
  class CppProjectConfiguration
    include DirectoryUtility
    include GeneralUtility
    
    attr_accessor :Name
    attr_accessor :SourceIncludePatterns
    attr_accessor :SourceExcludePatterns
    attr_accessor :HeaderIncludePatterns
    attr_accessor :HeaderExcludePatterns
    attr_accessor :SourceDirectories
    attr_accessor :HeaderDirectories
    attr_accessor :Defines
    attr_accessor :PrecompiledHeader
    attr_accessor :ProjectDirectory
    attr_accessor :CompilesDirectory
    attr_accessor :BuildDirectory
    attr_accessor :StaticLibraries
    attr_accessor :DynamicLibraries
    attr_accessor :BinaryName
    attr_accessor :BinaryType
    
    def initialize
      @Name = "default"
      @SourceIncludePatterns = []
      @SourceExcludePatterns = []
      @HeaderIncludePatterns = []
      @HeaderExcludePatterns = []
      @HeaderDirectories = []
      @SourceDirectories = []
      @Defines = []
      @PrecompiledHeader = nil
      @ProjectDirectory = nil
      @CompilesDirectory = "bin"
      @BuildDirectory = "build"
      @StaticLibraries = []
      @DynamicLibraries = []
      @BinaryName = nil
      @BinaryType = :application      
    end
    
    def initialize_copy(original)
      @SourceIncludePatterns = Clone(original.SourceIncludePatterns)
      @SourceExcludePatterns = Clone(original.SourceExcludePatterns)
      @HeaderIncludePatterns = Clone(original.HeaderIncludePatterns)
      @HeaderExcludePatterns = Clone(original.HeaderExcludePatterns)
      @HeaderDirectories = Clone(original.HeaderDirectories)
      @SourceDirectories = Clone(original.SourceDirectories)
      @Defines = Clone(original.Defines)
      @PrecompiledHeader = Clone(original.PrecompiledHeader)
      @ProjectDirectory = Clone(original.ProjectDirectory)
      @CompilesDirectory = Clone(original.CompilesDirectory)
      @StaticLibraries = Clone(original.StaticLibraries)
      @DynamicLibraries = Clone(original.DynamicLibraries)
      @BinaryName = Clone(original.BinaryName)
      @BinaryType = Clone(original.BinaryType)
    end
    
    # Return the source paths with the prepended project directory.
    def GetExtendedSourcePaths
      if(@ProjectDirectory == nil)
	raise "ProjectDirectory not set in project configuration"
      end
      
      return ExtendDirectoryPaths(@ProjectDirectory, @SourceDirectories)
    end
    
    # Return the include paths with the prepended project directory.
    def GetExtendedIncludePaths
      if(@ProjectDirectory == nil)
	raise "ProjectDirectory not set in project configuration"
      end
      
      return ExtendDirectoryPaths(@ProjectDirectory, @HeaderDirectories)
    end
    
    # Get the paths to all source files that are identified by the search patterns.
    def GetExtendedSources
      extendedSourcePaths = GetExtendedSourcePaths()
      extendedSources = FindFilesInDirectories(@SourceIncludePatterns, @SourceExcludePatterns, extendedSourcePaths)
      return extendedSources
    end
    
    # Get the paths to all include files that are identified by the search patterns.
    def GetExtendedIncludes
      extendedIncludePaths = GetExtendedIncludePaths()
      extendedIncludes = FindFilesInDirectories(@HeaderIncludePatterns, @HeaderExcludePatterns, extendedIncludePaths)
      return extendedIncludes
    end
    
    # Get the complete directory tree for each source directory.
    # This gathers all possible source paths for a project.
    def GetSourceDirectoryTree
      sourceDirs = []
      GetExtendedSourcePaths().each {|sourceDir|
                                      sourceDirs = sourceDirs + GetDirectoryTree(sourceDir, @SourceExcludePatterns)
                                     }
      return sourceDirs
    end
    
    # Get the complete directory tree for each include directory.
    # This gathers all possible include paths for a project.
    def GetIncludeDirectoryTree
      includeDirs = []
      GetExtendedIncludePaths().each {|includeDir|
                                      includeDirs = includeDirs + GetDirectoryTree(includeDir, @HeaderExcludePatterns)
                                     }
      return includeDirs
    end
    
    # Combines the name of the configuration and the compiles directory to form the directory where the compiles for the given configuration are stored.
    def GetFinalCompilesDirectory
      return JoinPaths([@CompilesDirectory, @Name])
    end
    
    # Combines the name of the configuration and the build directory to form the directory where the build results for the given configuration are stored.
    def GetFinalBuildDirectory
      return JoinPaths([@BuildDirectory, @Name])
    end
  end
  
end