require "rake"
require "VisualStudio/filter_file_creator"
require "VisualStudio/project_file_creator"
require "VisualStudio/solution_file_creator"
require "VisualStudio/vs_project_configuration_factory"
require 'UUID/uuidtools.rb'
require "directory_utility"

module RakeBuilder
  # Class that can create a visual studio project for compilation.
  class VsSolutionCreator
    include DirectoryUtility

    attr_accessor :BaseProjectConfiguration
    attr_accessor :VsProjectConfigurations
    attr_accessor :VsProjectDirectory
    attr_accessor :EndTask

    def initialize(baseProjectConfiguration)
      @EndTask = UUIDTools::UUID.random_create().to_s
      
      @BaseProjectConfiguration = baseProjectConfiguration
      @VsProjectConfigurations = []
      
      @VsProjectDirectory = "VsProjectTest"
      
      @filterFileCreator = FilterFileCreator.new()
      @projectFileCreator = ProjectFileCreator.new()
      @solutionFileCreator = SolutionFileCreator.new()
      @configurationFactory = VsProjectConfigurationFactory.new() 
    end
    
    def CreateNewVsProjectConfiguration(name)
        if(VsConfigurationExists(name))
          abort "The solution creator has already a configuration named #{name}"
        end
      
        newVsProjectConfiguration = VsProjectConfiguration.new()
        newVsProjectConfiguration.InitializeFromParent(@BaseProjectConfiguration)
        newVsProjectConfiguration.Name = name
        
        @VsProjectConfigurations.push(newVsProjectConfiguration)
        
        return newVsProjectConfiguration
    end

    def CreateTasks
      CreateProjectDirectoryTask()

      CreateFilterFileTask()
      CreateProjectFileTask()
    end

    def CreateProjectDirectoryTask
      @finalVsProjectDirectory = JoinPaths([@VsProjectDirectory] )
      directory @finalVsProjectDirectory
    end

    def CreateFilterFileTask
      CreateVsFile(@filterFileCreator)
    end

    def CreateProjectFileTask
        @VsProjectConfigurations.each do |vsProjectConfiguration|
          vsProjectConfiguration.SyncWithParent()
          @projectFileCreator.VsProjectConfigurations.push(vsProjectConfiguration)
        end
        
      CreateVsFile(@projectFileCreator)
    end

    def CreateVsFile(fileCreator)
      fileCreator.ProjectConfiguration = @BaseProjectConfiguration
      fileCreator.VsProjectDirectory = @finalVsProjectDirectory

      taskName = fileCreator.GetFilePath()

      file taskName => @finalVsProjectDirectory do
        fileCreator.BuildFile()
      end

      task @EndTask => taskName
    end
    
    def VsConfigurationExists(name)
      return GetVsConfiguration(name) != nil
    end
    
    def GetVsConfiguration(name)
      @VsProjectConfigurations.each do |configuration|
        if(configuration.Name.eql? name)
          return configuration
        end
      end
      
      return nil
    end
  end
end
