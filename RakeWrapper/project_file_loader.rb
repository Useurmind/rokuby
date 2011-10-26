module RakeBuilder
  # This class is used to load files.
  class ProjectFileLoader
    # A list of project files that were loaded.
    attr_accessor :LoadedProjectFiles
    
    def initialize
      @LoadedProjectFiles = []
    end
    
    # Load a project file from the given path.
    # This path is relative to the project files folder that loads the file.
    def LoadProjectFile(path)
      
      projectFile = ProjectFile.new()
      projectFile.Path = path
      
      load(path.AbsolutePath)
      
      @LoadedProjectFiles.push(projectFile)
      
      projectFile.ProjectFileIncludes.each do |projectFilePath|
        LoadProjectFile(projectFile)
      end
    end
  end
end
