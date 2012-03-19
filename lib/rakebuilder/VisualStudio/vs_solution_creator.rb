require "rake"

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
    attr_accessor :CleanTask
    
    def initialize(vsSolution)
      @EndTask = GenerateTaskName({
        projectName: vsSolution.SolutionName,
        type: "SolutionCreationTask"
      })
      @CleanTask = GenerateTaskName({
        projectName: vsSolution.SolutionName,
        type: "SolutionCleanTask"
      })
      
      @VsSolution = vsSolution
      @SubprojectBuilder = SubprojectBuilder.new()
      
      @solutionFileCreator = SolutionFileCreator.new()
      @solutionFileCreator.VsSolution = @VsSolution
    end

    def CreateTasks
      CreateProjectTasks()
      
      CreateSolutionDirectoryTask()

      CreateSolutionFileTask()
      
      task @CleanTask do
        rm_r @VsSolution.SolutionDirectory rescue nil
      end
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
          task @CleanTask => project.CleanVisualStudioTask
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
