require "directory_utility"


module RakeBuilder

  # This is a configuration for a C++ project.
  # It is independent of any type of build system and just includes the information
  # about the ingredients of the project.
  # [SourceIncludePatterns] Some RegExps that define the sources to include in the project.
  # [SourceExcludePatterns] Some RegExps which define the sources that should definitely not be included in the project.
  # [HeaderIncludePatterns] Some RegExps that define the headers to include in the project.
  # [HeaderExcludePatterns] Some RegExps which define the headers that should definitely not be included in the project.
  # [ProjectDirectory] The absolute path where the project is located.
  # [SourceDirectories] The directories in the ProjectDirectory for the source files.
  # [HeaderDirectories] The directories in the ProjectDirectory for the header files.
  # [CompilesDirectory] The directory in the ProjectDirectory for the compiled sources (defaults to 'bin').
  # [Defines] Defines that should be set for the project.
  # [PrecompiledHeader] The file that can be used as a precompiled header (visual studio)
  class CppProjectConfiguration
    include DirectoryUtility

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
    attr_accessor :BinaryName
    attr_accessor :BinaryType

    def initialize
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
      @BinaryName = nil
    end

    def GetExtendedSourcePaths
      if(@ProjectDirectory == nil)
        raise "ProjectDirectory not set in project configuration"
      end

      return ExtendDirectoryPaths(@ProjectDirectory, @SourceDirectories)
    end

    def GetExtendedIncludePaths
      if(@ProjectDirectory == nil)
        raise "ProjectDirectory not set in project configuration"
      end
      
      return ExtendDirectoryPaths(@ProjectDirectory, @HeaderDirectories)
    end

    def GetExtendedSources
      extendedSourcePaths = GetExtendedSourcePaths()
      extendedSources = FindFilesInDirectories(@SourceIncludePatterns, @SourceExcludePatterns, extendedSourcePaths)
      return extendedSources
    end

    def GetExtendedIncludes
      extendedIncludePaths = GetExtendedIncludePaths()
      extendedIncludes = FindFilesInDirectories(@HeaderIncludePatterns, @HeaderExcludePatterns, extendedIncludePaths)
      return extendedIncludes
    end

    def GetIncludeDirectoryTree
      includeDirs = []
      GetExtendedIncludePaths().each {|includeDir|
        includeDirs = includeDirs + GetDirectoryTree(includeDir, @HeaderExcludePatterns)
      }
      return includeDirs
    end
  end

end