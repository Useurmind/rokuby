module RakeBuilder
  # This class can create a solution file for Visual Studio 2010
  # [VsSolution] The solution for which the solution file should be build.
  class SolutionFileCreator
    include VsXmlFileUtility
    include GeneralUtility
    
    attr_accessor :VsSolutionDescription
    attr_accessor :VsProjects    
    
    def initialize
      @VsSolutionDescription = nil
      @VsProjects = []
      
      @Guid = GetUUID()
      @indentString = ""
    end
    
    def GetFilePath
      return @VsSolutionDescription.SolutionFilePath
    end
    
    def GetSolutionDirectory
      return @VsSolutionDescription.SolutionFilePath.DirectoryPath()
    end
    
    def BuildFile      
      if(@VsProjects.length == 0)
        abort "No project specified for solution file creation"
      end
      
      @fileContent = "\n"
      WriteLine("Microsoft Visual Studio Solution File, Format Version 11.00")
      WriteLine("\# Visual Studio 2010")
      
      @VsProjects.each do |project|
        CreateProjectWithDependencies(project)
      end
      
      StartGlobal()
      
      StartGlobalSection("SolutionConfigurationPlatforms", false)
        @VsProjects[0].Configurations.each do |configuration|
          WriteLine("#{configuration.NamePlatformCombi()} = #{configuration.NamePlatformCombi()}")
        end
      EndGlobalSection()
      
      StartGlobalSection("ProjectConfigurationPlatforms")
      WriteProjectConfigurationPlatforms()
      EndGlobalSection()
      
      StartGlobalSection("SolutionProperties", false)
      WriteLine("HideSolutionNode = FALSE")
      EndGlobalSection()
      
      EndGlobal()
      
      directory = GetFilePath().AbsoluteDirectory()
      Dir::mkdir(directory) unless File.exists?(directory)
      File.open(GetFilePath().AbsolutePath(), 'w') {|f| f.write(@fileContent) }
    end
    
    def WriteProjectConfigurationPlatforms()
      @VsProjects[0].Configurations.each do |configuration|
        @VsProjects.each do |project|
          configs = project.Configurations.select do |config|
            return (configuration.Name.eql? config.Name)
          end
          
          WriteLine("#{project.Guid}.#{configuration.NamePlatformCombi()}.ActiveCfg = #{configs[0].NamePlatformCombi()}")
          WriteLine("#{project.Guid}.#{configuration.NamePlatformCombi()}.Build.0 = #{configs[0].NamePlatformCombi()}")
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
      project.Dependencies.each do |dependency|
        StartProjectSection("ProjectDependencies")
      
        WriteLine("#{dependency.Guid} = #{dependency.Guid}") 
        
        EndProjectSection()
      end
    end
    
    # [guid] A guid in the form {35BC...}
    def StartProject(guid, project)
      solutionDirectory = GetSolutionDirectory()
      
      relativeProjectFilePath = FormatXmlPath(project.ProjectFilePath.MakeRelativeTo(solutionDirectory).RelativePath)
      WriteLine("Project(\"#{guid}\") = \"#{project.Name}\", \"#{relativeProjectFilePath}\", \"#{project.Guid}\"")
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
      @indentString = @indentString + "\t"
    end
    
    def DecreaseIndentation()
      if(@indentString.length == 1)
        @indentString = ""
      else
        @indentString = @indentString[0..@indentString.length-2]
      end
    end
  end
end
