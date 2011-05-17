require "VisualStudio/vs_xml_file_utility.rb"
require "general_utility"

module RakeBuilder
  class VsFileCreator
    include VsXmlFileUtility
    include GeneralUtility
    
    attr_accessor :VsProject

    def initialize
      @options = {
        "NoEscape" => true,
        "XmlDeclaration" => "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
        "RootName" => "Project"
      }
    end

    def BuildFile
      abort "BuildFile not implemented in #{self.class.name}"
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
      return GetProjectDirectoryRelativeBaseDirectory(@VsProject.GetProjectRelativePath(file))
    end

    # Get the path of the file relative to the visual studio project directory.
    def _GetVsProjectRelativePath(path)
      return GetVsProjectRelativePath(@VsProject.GetProjectRelativePath(path))
    end
  end
end
