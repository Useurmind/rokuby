module Rokuby
  # A base class for all objects that need to create files used by VisualStudio.
  class VsFileCreator
    include VsXmlFileUtility
    include GeneralUtility
    include DirectoryUtility
  
    attr_accessor :ProjectDescription
    attr_accessor :ProjectInstance
    attr_accessor :ProjectConfigurations
    attr_accessor :VsProjectInstance
    attr_accessor :VsProjectDescription
    attr_accessor :VsProjectConfigurations
    attr_accessor :VsProjects

    def initialize
      @ProjectDescription = nil
      @ProjectInstance = nil
      @ProjectConfigurations = []
      @VsProjectInstance = nil
      @VsProjectDescription = nil
      @VsProjectConfigurations = []
      @VsProjects = []
      
      @options = {
        "NoEscape" => true,
        "XmlDeclaration" => "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
        "RootName" => "Project"
      }
    end
    
    def CreateFileDirectory
      CreatePath(GetFilePath().DirectoryPath())
    end

    def BuildFile
      abort "BuildFile not implemented in #{self.class.name}"
    end

    # Get the name of the file that should be created by the file creator.
    def GetFileName()
      abort "GetFileName not implemented in #{self.class.name}"
    end
    
    # Concat all source units contained in the project instance into one source unit named @SourceUnit
    def _JoinSourceUnits
      @SourceUnit = SourceUnitInstance.new()
      for i in 0..@ProjectInstance.SourceUnits.length-1
        @SourceUnit = @SourceUnit + @ProjectInstance.SourceUnits[i]
      end
      
      @ResourceFileSet = @VsProjectInstance.ResourceFileSet
      @IdlFileSet = @VsProjectInstance.IdlFileSet
    end
    
    # Get the path of the file relative to the visual studio project directory.
    def _GetVsProjectRelativePath(path)
      return path.MakeRelativeTo(@VsProjectDescription.ProjectFilePath.DirectoryPath())
    end
  end
end
