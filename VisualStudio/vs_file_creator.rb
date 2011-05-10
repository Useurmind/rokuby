require "VisualStudio/vs_xml_file_utility.rb"

module RakeBuilder
  class VsFileCreator < VsXmlFileUtility
    attr_accessor :ProjectConfiguration
    attr_accessor :VsProjectDirectory

    def initialize
      super
    end

    def BuildFile
      abort "BuildFile not implemented in #{self.class.name}"
    end

    # Get the path of the file that should be created by the file creator.
    def GetFilePath()
      return JoinPaths([@VsProjectDirectory, GetFileName()])
    end

    # Get the name of the file that should be created by the file creator.
    def GetFileName()
      abort "GetFileName not implemented in #{self.class.name}"
    end

    # Return the directory of the given file path relative to the base directory of
    # the project.
    # The path will be formatted in visual studio xml path format.
    # Example: 'C:/../projectBase/include/header1.h' -> 'include\header1.h'
    def _GetProjectDirectoryRelativeBaseDirectory(file)
      return GetProjectDirectoryRelativeBaseDirectory(@ProjectConfiguration.GetProjectRelativePath(file))
    end

    # Get the path of the file relative to the visual studio project directory.
    def _GetVsProjectRelativePath(path)
      return GetVsProjectRelativePath(@ProjectConfiguration.GetProjectRelativePath(path))
    end

    # Get a UUID with surrounding brackets.
    # Example: {D9F40C8D-144E-4F80-8C74-1B1AAD84ADFB}
    def GetUUID
      return "\{#{UUIDTools::UUID.random_create().to_s}\}"
    end
  end
end
