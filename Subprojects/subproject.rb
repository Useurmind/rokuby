require "directory_utility"

module RakeBuilder
  
  # This class represents a subproject of the main project.
  # A subproject can be everything that must be build for a certain project configuration.
  # It is always associated with a subfolder of the project. Where the build and clean
  # commands are executed.
  # Subprojects can also have a task that will be executed after they were build.
  # They are also associated with some resulting files which can be checked for determining
  # if the project must be build again.
  # [Name] The name of the subproject.
  # [Folder] The folder where the subproject is located.
  # [BuildCommand] The command that will be executed to build the subproject.
  # [CleanCommand] The command that will be executed to clean the subproject.
  # [AfterBuildTask] The name of the task that should be executed after the build succeeds.
  # [ResultFiles] Some file paths relative to the subproject folder that determine the resulting files.
  class Subproject
    include DirectoryUtility
    
    attr_accessor :Name
    attr_accessor :Folder
    attr_accessor :BuildCommand
    attr_accessor :CleanCommand
    attr_accessor :AfterBuildTask
    attr_accessor :ResultFiles
    
    # [name] see Name.
    # [folder] see Folder.
    # [buildCommand] see BuildCommand.
    # [cleanCommand] see CleanCommand.
    # [afterBuildTask] see AfterBuildTask.
    # [resultFiles] see ResultFiles.
    def initialize(paramBag = {})      
      @Name = (paramBag[:name] or nil)
      @Folder = (paramBag[:folder] or nil)
      @BuildCommand = (paramBag[:buildCommand] or "rake")
      @CleanCommand = (paramBag[:cleanCommand] or "rake clean")
      @AfterBuildTask = (paramBag[:afterBuildTask] or nil)
      @ResultFiles = (paramBag[:resultFiles] or [])
    end
    
    # Get the result folders relative to the base project folder.
    def GetResultFilePaths
      resultFiles = []
      @ResultFiles.each do |file|
        resultFiles.push( JoinPaths([ @Folder, file ]) )
      end
      return resultFiles
    end
    
  end
  
end