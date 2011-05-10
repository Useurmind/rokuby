require "rake"
require "VisualStudio/filter_file_creator"
require "VisualStudio/project_file_creator"
require "VisualStudio/solution_file_creator"
require "VisualStudio/vs_project_configuration_factory"
require 'UUID/uuidtools.rb'
require "directory_utility"

module RakeBuilder
  # Class that can create a visual studio project for compilation.
  class VsProjectCreator
    include DirectoryUtility

    attr_accessor :ProjectConfiguration
    attr_accessor :VsProjectDirectory
    attr_accessor :EndTask

    def initialize
      @EndTask = UUIDTools::UUID.random_create().to_s
      @VsProjectDirectory = "VsProjectTest"
      @filterFileCreator = FilterFileCreator.new()
      @projectFileCreator = ProjectFileCreator.new()
      @solutionFileCreator = SolutionFileCreator.new()

      @releaseConfiguration = VsProjectConfiguration.new()
      @debugConfiguration = VsProjectConfiguration.new()

      @configurationFactory = VsProjectConfigurationFactory.new()

      @configurationFactory.SetDebugValues(@debugConfiguration)

      @projectFileCreator.ProjectConfigurations.push( @releaseConfiguration )
      @projectFileCreator.ProjectConfigurations.push( @debugConfiguration )
    end

    def CreateTasks
      @configurationFactory.ConvertFromProjectConfiguration(@releaseConfiguration, @ProjectConfiguration)
      @configurationFactory.ConvertFromProjectConfiguration(@debugConfiguration, @ProjectConfiguration)

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
      CreateVsFile(@projectFileCreator)
    end

    def CreateVsFile(fileCreator)
      fileCreator.ProjectConfiguration = @ProjectConfiguration
      fileCreator.VsProjectDirectory = @finalVsProjectDirectory

      taskName = fileCreator.GetFilePath()

      file taskName => @finalVsProjectDirectory do
        fileCreator.BuildFile()
      end

      task @EndTask => taskName
    end
  end
end
