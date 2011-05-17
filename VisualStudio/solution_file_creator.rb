require "directory_utility"

module RakeBuilder
  # This class can create a solution file for Visual Studio 2010
  # [VsSolution] The solution for which the solution file should be build.
  class SolutionFileCreator
    include DirectoryUtility
    
    attr_accessor :VsSolution
    
    def initialize
      @Guid = GetUUID()
      @indentString = ""
    end
    
    def GetFilePath
      return JoinPaths([ @VsSolution.SolutionDirectory, GetFileName() ])
    end
    
    def GetFileName
      return "#{@VsSolution.SolutionName}.sln"
    end
    
    def BuildFile      
      if(@VsSolution.Projects.length == 0)
        abort "No project specified for solution file creation"
      end
      
      @fileContent = "\n"
      WriteLine("Microsoft Visual Studio Solution File, Format Version 11.00")
      WriteLine("\# Visual Studio 2010")
      
      @VsSolution.Projects.each do |project|
        CreateProjectWithDependencies(project)
      end
      
      StartGlobal()
      
      StartGlobalSection("SolutionConfigurationPlatforms", false)
        @VsSolution.Projects[0].VsProjectConfigurations.each do |configuration|
          WriteLine("#{configuration.GetNamePlatformCombi()} = #{configuration.GetNamePlatformCombi()}")
        end
      EndGlobalSection()
      
      StartGlobalSection("ProjectConfigurationPlatforms")
      WriteProjectConfigurationPlatforms()
      EndGlobalSection()
      
      StartGlobalSection("SolutionProperties", false)
      WriteLine("HideSolutionNode = FALSE")
      EndGlobalSection()
      
      EndGlobal()
      
      File.open(GetFilePath(), 'w') {|f| f.write(@fileContent) }
    end
    
    def WriteProjectConfigurationPlatforms()
      @VsSolution.Projects[0].VsProjectConfigurations.each do |configuration|
        @VsSolution.Projects.each do |project|
          configs = project.VsProjectConfigurations.select do |config|
            return (configuration.Name.eql? config.Name)
          end
          
          WriteLine("#{project.Guid}.#{configuration.GetNamePlatformCombi()}.ActiveCfg = #{configs[0].GetNamePlatformCombi()}")
          WriteLine("#{project.Guid}.#{configuration.GetNamePlatformCombi()}.Build.0 = #{configs[0].GetNamePlatformCombi()}")
        end
      end
    end
    
    def CreateProjectWithDependencies(project)
      StartProject(@Guid, project)
      
      if(project.Dependencies.length > 0)
        WriteProjectDependencies(project)        
      end
      
      EndProject()
    end
    
    def WriteProjectDependencies(project)
      project.Dependencies.each do |dependeny|
        StartProjectSection("ProjectDependencies")
      
        WriteLine("#{dependeny.Guid} = #{dependeny.Guid}") 
        
        EndProjectSection()
      end
    end
    
    # [guid] A guid in the form {35BC...}
    def StartProject(guid, project)
      WriteLine("Project(\"#{guid}\") = \"#{project.Name}\", \"#{project.ProjectFilePath}\", \"#{project.Guid}\"")
      IncreaseIndentation()
    end
    
    def EndProject
      DecreaseIndentation()
      WriteLine("EndProject")
    end
    
    def StartProjectSection(name)      
      WriteLine("ProjectSection(#{name}) = postProject")
      IncreaseIndentation()
    end
    
    def EndProjectSection
      DecreaseIndentation()
      WriteLine("EndProjectSection")
    end
    
    def StartGlobal
      WriteLine("Global")
      IncreaseIndentation()
    end
    
    def EndGlobal
      DecreaseIndentation()
      WriteLine("EndGlobal")
    end
    
    def StartGlobalSection(name, postSolution=true)
      solutionString = GetSolutionString(postSolution)
      
      WriteLine("GlobalSection(#{name}) = #{solutionString}")
      IncreaseIndentation()
    end
    
    def EndGlobalSection()
      DecreaseIndentation()
      WriteLine("EndGlobalSection")
    end
    
    def GetSolutionString(postSolution = true)
      solutionString = "postSolution"
      if(!postSolution)
        solutionString = "preSolution"
      end
      return solutionString
    end
    
    def WriteLine(content)
      @fileContent << @indentString << content << "\n"
    end
    
    def IncreaseIndentation()
      puts "Incr indent (indent level #{@indentString.length+1})"
      @indentString = @indentString + "\t"
    end
    
    def DecreaseIndentation()
      puts "Decr indent (indent level #{@indentString.length-1})"
      if(@indentString.length == 1)
        @indentString = ""
      else
        @indentString = @indentString[0..@indentString.length-2]
      end
    end
  end
end
