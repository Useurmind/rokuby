require "rake"
require "Subprojects/subproject_builder"
require "VisualStudio/filter_file_creator"
require "VisualStudio/project_file_creator"
require "VisualStudio/solution_file_creator"
require "VisualStudio/vs_project_configuration_factory"
require "VisualStudio/vs_project"
require "VisualStudio/vs_subproject"
require 'UUID/uuidtools.rb'
require "directory_utility"
require "general_utility"

module RakeBuilder
  # Class that can create a visual studio project for compilation.
  # [SolutionName] The name for the solution.
  # [VsSolutionDirectory] The name of the directory under the base directory where to put the solution.
  #                       All projects will be located in subdirectories of it.
  # [ProjectCreators] The VsProjectCreators that will create the single project files.
  # [SubProjects] The VsSubproject instances that represent external projects.
  class VsSolutionCreator
    include DirectoryUtility
    include GeneralUtility

    attr_accessor :VsSolution
    attr_accessor :SubprojectBuilder
    attr_accessor :EndTask
    
    def initialize(vsSolution)
      @EndTask = "SolutionCreationTask_#{vsSolution.SolutionName}_#{UUIDTools::UUID.random_create().to_s}"
      
      @VsSolution = vsSolution
      @SubprojectBuilder = SubprojectBuilder.new()
      
      @solutionFileCreator = SolutionFileCreator.new()
      @solutionFileCreator.VsSolution = @VsSolution
    end

    def CreateTasks
      CreateProjectTasks()
      
      CreateSolutionDirectoryTask()

      CreateSolutionFileTask()
    end
    
    def CreateProjectTasks()
      @projectCreators = []
      
      @VsSolution.Projects.each do |project|
        if(project.class.name.eql? VsProject.name)
          projectCreator = VsProjectCreator.new(project)
          projectCreator.VsSolutionDirectory = @VsSolution.SolutionDirectory
          projectCreator.CreateTasks()
          
          file @solutionFileCreator.GetFilePath() => [projectCreator.EndTask]
          
          @projectCreators.push(projectCreator)
        elsif(project.class.name.eql? VsSubproject.name)
          @SubprojectBuilder.Subprojects.push(project)
        end
      end
      @SubprojectBuilder.BuildSubprojectTasks()
      file @solutionFileCreator.GetFilePath() => [@SubprojectBuilder.SubprojectTask]
    end

    def CreateSolutionDirectoryTask()
      @finalVsSolutionDirectory = JoinPaths([@VsSolution.SolutionDirectory] )
      directory @finalVsSolutionDirectory
    end
    
    def CreateSolutionFileTask
      file @solutionFileCreator.GetFilePath() => @finalVsSolutionDirectory do
        @solutionFileCreator.BuildFile()
      end
      
      task @EndTask => @solutionFileCreator.GetFilePath()
    end
  end
end
