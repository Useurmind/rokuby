module RakeBuilder
  # A set of files that is present on this system.
  # [FilePaths] An array of project paths for files that were found based on the patterns and paths defined above.
  # [FileDirectories] An array of project paths for the directories that include the files.
  # [BaseDirectories] An array of project paths for the topmost directories that include the files.
  class FileSet < InformationInstance
    
    attr_accessor :FilePaths
    attr_accessor :FileDirectories
    attr_accessor :RootDirectories
    
    def initialize
      super
      @FilePaths = []
      @FileDirectories = []
      @RootDirectories = []
    end
    
    def initialize_copy(original)
      super(original)
      @FilePaths = Clone(original.FilePaths)
      @FileDirectories = Clone(original.FileDirectories)
      @RootDirectories = Clone(original.RootDirectories)
    end
    
    def to_s
      val = ""
      val += "Files: #{@FilePaths}\n"
      val += "File Directories: #{@FileDirectories}\n"
    end
  end
end