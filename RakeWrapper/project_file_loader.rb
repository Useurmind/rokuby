module RakeBuilder
  # This class is used to load files.
  # Implements the rake loader interface.
  class ProjectFileLoader
    include PathUtility
    
    # A list of project files that were loaded.
    attr_accessor :LoadedProjectFiles
    
    #The project file that is currently loaded
    attr_reader :CurrentlyLoadedProjectFile
    
    def initialize
      @LoadedProjectFiles = []
    end
    
    # Load a project file from the given path.
    # This path is NOT a project path, because this class needs to implement the
    # Rak::Loader interface.
    def load(path)
      projectPath = ProjectPath.new(path)
      
      projectFile = ProjectFile.new()
      projectFile.Path = projectPath
      
      ExecuteInPath(projectFile.Path) do
        @CurrentlyLoadedProjectFile = projectFile
        load(projectFile.Path.AbsolutePath)
        
        @LoadedProjectFiles.push(projectFile)
        
        projectFile.ProjectFileIncludes.each do |projectFilePath|
          LoadProjectFile(projectFile.Path + projectFilePath)
        end      
      end
    end
  end
end
