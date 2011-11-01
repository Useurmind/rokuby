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
      @LoadedProjectFiles = {}
    end
    
    # Load a project file from the given path.
    # This path is NOT a project path, because this class needs to implement the
    # Rak::Loader interface.
    def load(path)
      puts "Loading project file #{path}" 
      projectPath = ProjectPath.new(path)
      
      LoadProjectFile(projectPath)
    end
    
    def LoadProjectFile(projectPath)
      projectFile = ProjectFile.new()
      projectFile.Path = projectPath
      
      ExecuteInPath(projectFile.Path.DirectoryPath().MakeAbsolute()) do
        @CurrentlyLoadedProjectFile = projectFile
        
        if(!projectFile.Path.file?())
          raise "Could not find project file '#{projectFile.Path.AbsolutePath()}'"
        end
        
        projectFile.DefineCleanTasks
        
        Kernel.load(projectFile.Path.AbsolutePath())
        
        @LoadedProjectFiles[projectFile.Path().RelativePath] = projectFile
        
        puts projectFile.ProjectFileIncludes
        projectFile.ProjectFileIncludes.each do |projectFilePath|
          puts "Loading child includes of project file"
          LoadProjectFile(projectFile.Path.DirectoryPath() + projectFilePath)
        end      
      end
    end
    
    def to_s
      val = "Loaded Project Files:\n"
      val += "-----------------------------------------------\n"
      @LoadedProjectFiles.each do |projectFile|
         val += projectFile.to_s
         val += "-----------------------------------------------\n"
      end
      return val
    end
  end
end
