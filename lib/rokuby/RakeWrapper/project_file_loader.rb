module Rokuby
  # This class is used to load project files.
  # Project file includes are loaded as soon as a project file include is defined.
  # Implements the rake loader interface.
  class ProjectFileLoader
    include PathUtility
    
    # A list of project files that were loaded.
    def LoadedProjectFiles
      @LoadedProjectFilesList
    end
    
    def LoadedProjectFile(path)
      @LoadedProjectFilesMap[path]
    end
    
    #The project file that is currently loaded
    def CurrentlyLoadedProjectFile
      @CurrentlyLoadedProjectFileStack[-1]
    end
    
    def initialize
      @LoadedProjectFilesMap = {}
      @LoadedProjectFilesList = []
      @CurrentlyLoadedProjectFileStack = []
    end
    
    # Load a project file from the given path.
    # This path is NOT a project path, because this class needs to implement the
    # Rake::Loader interface.
    def load(path)      
      #puts "Loading project file #{path}" 
      projectPath = ProjectPath.new(path)
      
      if(!projectPath.exist?() || !projectPath.file?())
        currentlyLoadedProjectFileString = (CurrentlyLoadedProjectFile() == nil) ? "nil" : CurrentlyLoadedProjectFile().Path.to_s
        raise "Could not find project file '#{path}' to load. Currently loaded project files is #{currentlyLoadedProjectFileString}"
      end
      
      LoadProjectFile(projectPath)
    end
    
    def LoadProjectFile(projectPath)
      #puts "Loading project file #{projectPath}"
      projectFile = ProjectFile.new()
      projectFile.Path = projectPath
      
      ExecuteInPath(projectFile.Path.DirectoryPath().MakeAbsolute()) do
        if(CurrentlyLoadedProjectFile() != nil)
          CurrentlyLoadedProjectFile().ProjectFileIncludes.push(projectFile.Path())
        end
        
        @LoadedProjectFilesMap[projectFile.Path().RelativePath] = projectFile
        @LoadedProjectFilesList.push(projectFile)
        
        @CurrentlyLoadedProjectFileStack.push(projectFile)
        
        if(!projectFile.Path.file?())
          raise "Could not find project file '#{projectFile.Path.AbsolutePath()}'"
        end
        
        projectFile.DefineCleanTasks
        
        projectFile.DefaultProjectConfigurations = Rokuby::Defaults.InitDefaultProjectConfigurations()
        projectFile.DefaultVsProjectConfigurations = Rokuby::Defaults.InitDefaultVsProjectConfigurations()
        projectFile.DefaultGppProjectConfigurations = Rokuby::Defaults.InitDefaultGppProjectConfigurations()
        
        Kernel.load(projectFile.Path.AbsolutePath())
        
        @CurrentlyLoadedProjectFileStack.delete_at(-1)
      end
    end
    
    def to_s
      val = "Loaded Project Files:\n"
      val += "-----------------------------------------------\n"
      LoadedProjectFiles().each do |projectFile|
         val += projectFile.to_s
         val += "-----------------------------------------------\n"
      end
      return val
    end
  end
end
