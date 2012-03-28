module RakeBuilder
    # Class that provides the means to handle task paths.
    module TaskPathUtility
        def Absolute?(taskPath)
            return taskPath.class != Symbol && taskPath =~ /^[A-Z]+:\//
        end
        
        # Is this task path a name only.
        def NameOnly?(taskPath)
            return !Absolute?(taskPath) && !(taskPath =~ /.*:.*/)
        end
        
        # Get the name contained in this task path
        def Name(taskPath)
            projectFilePath, name = GetProjectFilePathName(taskPath)
            return name
        end
        
        # Get the name contained in this task path
        def GetProjectFilePath(taskPath)
            projectFilePath, name = GetProjectFilePathName(taskPath)
            return projectFilePath
        end
        
        # Get the path to the project file and the name of the task
        def GetProjectFilePathName(taskPath)
            projectPath = nil
            name = nil
            
            if(NameOnly?(taskPath))
                name = taskPath.to_s
                return projectPath, name
            end
            
            match = taskPath.match("^([^:]*):(.*)$")
            if(match)
              projectPath = ProjectPath.new(match[1])
              name = match[2]
            else
              name = taskPath
            end
            
            return projectPath, name
        end
        
        # Convert a task path relative to the given project file into an absolute task path.
        def AbsoluteTaskPath(taskPath, projectFile)            
            projectFilePath, name = GetProjectFilePathName(taskPath)
            
            absoluteTaskPath = ""
            if(!projectFilePath)
                absoluteTaskPath = projectFile.Path().RelativePath
            else
                absoluteTaskPath = (projectFile.Path().DirectoryPath() + projectFilePath).RelativePath
            end
            
            absoluteTaskPath += ":" + name
            
            return absoluteTaskPath
        end
        
        def MakeRelativeTo(taskPath, projectFile)
            projectFilePath, name = GetProjectFilePathName(taskPath)
            
            if(projectFilePath)
                relProjectFilePath = projectFilePath.MakeRelativeTo(projectFile.Path.DirectoryPath())
                return relProjectFilePath.RelativePath + ":" + name
            else
                return name
            end
        end
    end
end
