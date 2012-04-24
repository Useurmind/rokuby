module RakeBuilder
    # Class that provides the means to handle task paths.
    module TaskPathUtility
        def AbsoluteTaskPathOnly?(taskPath)
            return taskPath.class != Symbol && taskPath =~ /^[A-Z]+:\/[^:]*$/
        end
        
        # Is this task path a name only.
        def NameOnly?(taskPath)
            return AbsoluteTaskPathOnly?(taskPath) || taskPath =~ /^[^:]*$/
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
            
            match = taskPath.match(/(^([A-Za-z]:\/)*[^:]*):*(.*)/)
            if(match)
              projectPath = ProjectPath.new(match[1])
              name = match[3]
            else
              name = taskPath
            end
            
            return projectPath, name
        end
        
        # Get the path of the project file of the task relative to the project file given and the name of the task
        def _GetTaskProjectFilePathName(taskPath, projectFile)
            projectFilePath, name = GetProjectFilePathName(taskPath)
            
            #puts "projectfile path: #{projectFilePath}"
            #puts "name: #{name}"
            
            taskProjectFilePath = ""
            if(!projectFilePath)
                taskProjectFilePath = projectFile.Path()
            else
                taskProjectFilePath = (projectFile.Path().DirectoryPath() + projectFilePath)
            end
            
            return taskProjectFilePath, name
        end
        
        # Get a task path relative to the application base directory
        def ApplicationBasedTaskPath(taskPath, projectFile)
            taskProjectFilePath, taskName = _GetTaskProjectFilePathName(taskPath, projectFile)
            return taskProjectFilePath.RelativePath + ":" + taskName
        end
        
        # Convert a task path relative to the given project file into an absolute task path.
        def AbsoluteTaskPath(taskPath, projectFile)            
            taskProjectFilePath, taskName = _GetTaskProjectFilePathName(taskPath, projectFile)
            return taskProjectFilePath.AbsolutePath() + ":" + taskName
        end
        
        # Make an absolute task path relative to the given project file
        def MakeRelativeTo(taskPath, projectFile)
            #puts "Making path #{taskPath} relative to #{projectFile.Path}"
            projectFilePath, name = GetProjectFilePathName(taskPath)
                
            if(projectFilePath)
                #puts "Project file path: #{projectFilePath}"
                relProjectFilePath = projectFilePath.MakeRelativeTo(projectFile.Path.DirectoryPath())
                return relProjectFilePath.RelativePath + ":" + name
            else
                return name
            end
        end
    end
end
