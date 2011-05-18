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
        
        CreateCopyLocalTask(vsProjectConfiguration)
      end
      
      @projectFileCreator.VsProject = @VsProject
        
      return CreateVsFileTask(@projectFileCreator)
    end
    
    def CreateCopyLocalTask(vsProjectConfiguration)
        vsProjectConfiguration.PostBuildCommand = "rake #{GetCopyLocalTaskName(vsProjectConfiguration)}"
        
        task GetCopyLocalTaskName(vsProjectConfiguration)
        vsProjectConfiguration.Libraries.each do |libContainer|
            if(!libContainer.UsedInWindows())
                next
            end
            
            library = libContainer.GetLibraryForOs(:Windows)
            fullLibraryPath = ""
            fileName = ""
            if(library.class.name.eql? WindowsLib.name)
                fullLibraryPath = library.GetFullDllPath()
                fileName = library.DllName
            else
                fullLibraryPath = libContainer.GetFullPath(:Windows)
                fileName = libContainer.GetFileName(:Windows)
            end            
            
            if(fullLibraryPath == nil)
                # library is in global library store, nothing to copy
                next
            end
            
            copyPath = JoinPaths( [vsProjectConfiguration.GetFinalBuildDirectory(), fileName ] )
            
            puts "copying lib #{copyPath} from #{fullLibraryPath}"
            file copyPath => [fullLibraryPath] do
              SystemWithFail("cp #{fullLibraryPath} #{copyPath}")
            end
            task GetCopyLocalTaskName(vsProjectConfiguration) => [copyPath]
        end
    end
    
    def GetCopyLocalTaskName(vsProjectConfiguration)
        return "copyLocal_#{vsProjectConfiguration.GetConfigurationSubdirectoryName()}"
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
