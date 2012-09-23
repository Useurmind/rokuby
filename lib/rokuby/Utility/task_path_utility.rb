module Rokuby
    # Class that provides the means to handle task paths.
    module TaskPathUtility
        def AbsoluteTaskPathOnly?(taskPath)
            return taskPath.class != Symbol && taskPath =~ /^[A-Z]+:\/[^:]*$/
        end
        
        # Is this task path a name only.
        def NameOnly?(taskPath)
            return AbsoluteTaskPathOnly?(taskPath) || taskPath =~ /^[^:]*$/
        end
        
        def JoinTaskPathName(path, name)
            return "#{path}:#{name}"
        end
        
        # Split a task path in path and name of the task.
        def SplitTaskPath(taskPath)
            path = nil
            name = nil
            
            if(!taskPath)
                return path, name
            end
            
            if(NameOnly?(taskPath))
                name = taskPath.to_s
                return path, name
            end
            
            match = taskPath.match(/(^([A-Za-z]:\/)*[^:]*):*(.*)/)
            if(match)
              path = match[1]
              name = match[3]
            else
              name = taskPath
            end
            
            return path, name
        end
        
        # Get the name contained in this task path
        def GetTaskName(taskPath)
            name = GetProjectFilePathName(taskPath)[1]
            return name
        end
        
        # Get the name contained in this task path
        def GetProjectFilePath(taskPath)
            projectFilePath = GetProjectFilePathName(taskPath)[0]
            return projectFilePath
        end
        
        # Get the path to the project file and the name of the task
        # The path to the project file
        def GetProjectFilePathName(taskPath)
            projectPath = nil
            name = nil
            
            path, name = SplitTaskPath(taskPath)
            
            if(path)
                projectPath = ProjectPath.new(path)
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
                #puts "Adding #{projectFile.Path().DirectoryPath()} and #{projectFilePath}"
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
