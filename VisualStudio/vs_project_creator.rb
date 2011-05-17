require "rake"
require "VisualStudio/filter_file_creator"
require "VisualStudio/project_file_creator"
require "VisualStudio/vs_project_configuration_factory"
require "VisualStudio/vs_project"
require 'UUID/uuidtools.rb'
require "directory_utility"
require "general_utility"

module RakeBuilder
  # Class that can create a visual studio project for compilation.
  class VsProjectCreator
    include DirectoryUtility
    include GeneralUtility

    attr_accessor :VsSolutionDirectory
    attr_accessor :VsProject
    attr_accessor :EndTask

    def initialize(vsProject)
        @EndTask = UUIDTools::UUID.random_create().to_s
        
        @VsProject = vsProject
        @VsSolutionDirectory = nil
        
        @filterFileCreator = FilterFileCreator.new()
        @projectFileCreator = ProjectFileCreator.new()
        @configurationFactory = VsProjectConfigurationFactory.new()        
        
        @filterFileCreator.VsProject = @VsProject
        @projectFileCreator.VsProject = @VsProject
    end

    def CreateTasks
        CreateFinalProjectDirectory()
        CreateProjectDirectoryTask()

        @filterFileTaskName = CreateFilterFileTask()
        @projectFileTaskName = CreateProjectFileTask()
    end

    def CreateFinalProjectDirectory
        @finalVsProjectDirectory = JoinPaths([@VsSolutionDirectory, @VsProject.ProjectName] )
        
        
        @VsProject.ProjectFilePath = JoinPaths( [ @finalVsProjectDirectory, @projectFileCreator.GetFilePath() ])
    end

    def CreateProjectDirectoryTask
      directory @finalVsProjectDirectory 
    end

    def CreateFilterFileTask
      return CreateVsFileTask(@filterFileCreator)
    end

    def CreateProjectFileTask
      @VsProjectConfigurations.each do |vsProjectConfiguration|
        vsProjectConfiguration.SyncWithParent()
        @projectFileCreator.VsProjectConfigurations.push(vsProjectConfiguration)
      end
        
      return CreateVsFileTask(@projectFileCreator)
    end

    def CreateVsFileTask(fileCreator)
      taskName = fileCreator.GetFilePath()

      file taskName => @finalVsProjectDirectory do
        fileCreator.BuildFile()
      end
      
      task @EndTask => taskName
      
      return taskName
    end
  end
end
