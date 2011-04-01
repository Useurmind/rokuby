require "directory_utility"
require "general_utility"
require "subproject"

module RakeBuilder
  
  class SubprojectBuilder
    include DirectoryUtility
    include GeneralUtility
    
    attr_accessor :Subprojects
    attr_accessor :SubprojectTask
    
    def initialize
      @Subprojects = []
      @SubprojectTask = "subtask"
    end
    
    def BuildSubprojectTask
      projectDir = Dir.pwd
      
      @Subprojects.each { |subproject|
	subdir = JoinPaths([projectDir, subproject.Folder])
                        
	task subproject.Name do
	  Dir.chdir(subdir)
	  SystemWithFail(subproject.BuildCommand, "Failed to build subproject #{subproject.Name}")
	  Dir.chdir(projectDir)
	end
                        
	task @SubprojectTask => [subproject.Name]
      }
    end
    
    def AddRakeSubproject(name, folder, target="")
      AddSubproject(name, folder, "rake #{target}")
    end
    
    def AddSubproject(name, folder, buildcommand="rake")
      @Subprojects.push(Subproject.new(name, folder, buildcommand))
    end
    
  end
  
end