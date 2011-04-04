require "directory_utility"
require "general_utility"
require "subproject"
require 'UUID/uuidtools.rb'

module RakeBuilder
  
  class SubprojectBuilder
    include DirectoryUtility
    include GeneralUtility
    
    attr_accessor :Subprojects
    attr_accessor :SubprojectTask
    
    def initialize
      @Subprojects = []
      @SubprojectTask = UUIDTools::UUID.random_create().to_s
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
                        
        cleanSubtask = "#{subproject.Name}_clean"
                        
        task cleanSubtask do
          Dir.chdir(subdir)              
	  SystemWithFail(subproject.CleanCommand, "Failed to clean subproject #{subproject.Name}")
          Dir.chdir(projectDir)
        end                        
	task :clean => cleanSubtask
                        
	task @SubprojectTask => [subproject.Name]
      }
    end
    
    def AddRakeSubproject(name, folder, target="")
      AddSubproject(name, folder, "rake #{target}")
    end
    
    def AddSubproject(name, folder, buildcommand="rake", cleanCommand="rake clean")
      @Subprojects.push(Subproject.new(name, folder, buildcommand, cleanCommand))
    end
    
  end
  
end