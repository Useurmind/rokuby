require "directory_utility"
require "general_utility"
require "Subprojects/subproject"
require 'UUID/uuidtools.rb'

module RakeBuilder
  
  # This class can be used to build subprojects.
  # You can add subprojects to this class by calling the methods: 
  #   - AddRakeSubproject
  #   - AddSubproject
  # After the subprojects are defined the necessary tasks must be build by calling:
  #   - BuildSubprojectTask
  # Finally, the build tasks must be given the subproject task as a dependency.
  class SubprojectBuilder
    include DirectoryUtility
    include GeneralUtility
    
    attr_accessor :Subprojects
    attr_accessor :SubprojectTask
    
    def initialize
      @Subprojects = []
      @SubprojectTask = "SubprojectBuilderTask_#{UUIDTools::UUID.random_create().to_s}"
      task @SubprojectTask
    end
    
    # Build the tasks that are necessary to build the subprojects.
    # The tasks are gathered in the subproject task of this object, which means that the subproject task is the only necessary dependency for other tasks that depend on the subprojects.
    # The tasks also include an extension of the clean task, so that each subproject is cleaned when calling rake clean.
    def BuildSubprojectTasks
      projectDir = Dir.pwd
      
      @Subprojects.each do |subproject|
        subdir = JoinPaths([projectDir, subproject.Folder])
        
        resultFilePaths = subproject.GetResultFilePaths()
        allFilesExist = true
        resultFilePaths.each do |filePath|
          if(!File.exists?(filePath))
            allFilesExist = false
            break
          end
        end
        
        if(allFilesExist)
          # if all needed files exist we do not need to build the subproject
          puts "All files for subproject #{subproject.Name} exist. Doing nothing."
          return
        end
        
        task GetSubprojectTaskName(subproject.Name) do
          Dir.chdir(subdir)
          SystemWithFail(subproject.BuildCommand, "Failed to build subproject #{subproject.Name}")
          Dir.chdir(projectDir)
        end
        
        cleanSubtask = GetSubprojectCleanTaskName(subproject.Name)
        
        task cleanSubtask do
          Dir.chdir(subdir)              
          SystemWithFail(subproject.CleanCommand, "Failed to clean subproject #{subproject.Name}")
          Dir.chdir(projectDir)
        end                        
        task :clean => cleanSubtask
        
        buildTaskName = GetSubprojectTaskName(subproject.Name)
        if(subproject.AfterBuildTask)
          task subproject.AfterBuildTask => buildTaskName
          buildTaskName = subproject.AfterBuildTask
        end
        
        task @SubprojectTask => [buildTaskName]
      end
    end
    
    # Get the name for the task that should build a subproject.
    # [subprojectName] The name of the subproject.
    def GetSubprojectTaskName(subprojectName)
      return "SubprojectTask_#{subprojectName}"
    end
    
    # Get the name for the task that should clean a subproject.
    # [subprojectName] The name of the subproject.
    def GetSubprojectCleanTaskName(subprojectName)
      return "#{subprojectName}_clean"
    end
    
    # Add a subproject that uses rake for building.
    # [name] A name identifying the subproject.
    # [folder] The base folder of the subproject (where the rakefile resides)
    # [target] The target for the rake call (not necessary for default target)
    def AddRakeSubproject(name, folder, target="")
      AddSubproject(name, folder, "rake #{target}")
    end
    
    # Add a generic subproject.
    # The only thing that is needed for such a subproject is a valid build and clean command.
    # The build command is executed in the given folder.
    # [name] A name identifying the subproject.
    # [folder] The base folder of the subproject (where the build command should be executed)
    # [buildcommand] The command to execute when building this subproject.
    # [cleanCommand] The command to execute when cleaning this subproject.
    def AddSubproject(name, folder, buildcommand="rake", cleanCommand="rake clean")
      @Subprojects.push(Subproject.new(name, folder, buildcommand, cleanCommand))
    end
    
  end
  
end