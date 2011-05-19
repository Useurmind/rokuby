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
        @EndTask = "ProjectCreationTask_#{vsProject.Name}_#{UUIDTools::UUID.random_create().to_s}"
        
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
                
        @VsProject.ProjectFilePath = JoinPaths( [ @finalVsProjectDirectory, @projectFileCreator.GetFileName() ])
        @VsProject.FilterFilePath = JoinPaths( [ @finalVsProjectDirectory, @filterFileCreator.GetFileName() ])
    end

    def CreateProjectDirectoryTask
      directory @finalVsProjectDirectory 
    end

    def CreateFilterFileTask
      return CreateVsFileTask(@filterFileCreator)
    end

    def CreateProjectFileTask
      @VsProject.VsProjectConfigurations.each do |vsProjectConfiguration|
        vsProjectConfiguration.SyncWithParent()
        
        CreatePostBuildTask(vsProjectConfiguration)
      end
      
      @projectFileCreator.VsProject = @VsProject
        
      return CreateVsFileTask(@projectFileCreator)
    end
    
    def CreatePostBuildTask(vsProjectConfiguration)
        vsProjectConfiguration.PostBuildCommand = "rake #{GetPostBuildTaskName(vsProjectConfiguration)}"
        
        task GetPostBuildTaskName(vsProjectConfiguration)
        vsProjectConfiguration.Libraries.each do |libContainer|
            if(!libContainer.UsedInWindows())
                next
            end
            
            fullLibraryPath = libContainer.GetFullCopyFilePath(:Windows)
            fileName = libContainer.GetCopyFileName(:Windows)
            
            if(fullLibraryPath == nil)
                # library is in global library store, nothing to copy
                next
            end
            
            copyPath = JoinPaths( [vsProjectConfiguration.GetFinalBuildDirectory(), fileName ] )
            
            file copyPath => [fullLibraryPath] do
              SystemWithFail("cp #{fullLibraryPath} #{copyPath}")
            end
            task GetPostBuildTaskName(vsProjectConfiguration) => [copyPath]
        end
        task GetPostBuildTaskName(vsProjectConfiguration) do
          vsProjectConfiguration.ExecuteAdditionalPostBuildAction()
        end
        @VsProject.Dependencies.each do |dependency|
          if(dependency.class.name.eql? VsSubproject.name)
            task GetPostBuildTaskName(vsProjectConfiguration) do
              dependency.CopyBuildResultsToPath(vsProjectConfiguration.Name, vsProjectConfiguration.GetFinalBuildDirectory())
            end
          end
        end
    end
    
    def GetPostBuildTaskName(vsProjectConfiguration)
        return "PostBuild_#{vsProjectConfiguration.GetConfigurationSubdirectoryName()}"
    end

    def CreateVsFileTask(fileCreator)
      taskName = JoinPaths( [ @finalVsProjectDirectory, fileCreator.GetFileName() ])

      file taskName => @finalVsProjectDirectory do
        fileCreator.BuildFile()
      end
      
      task @EndTask => taskName
      
      return taskName
    end
  end
end
