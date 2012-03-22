module RakeBuilder
  module GeneralUtility    
    # Execute a system call with the given command.
    # Ob failure print the message if print is set to true.
    def SystemWithFail(command, message="", print=true)      
      if(print)
        puts "'#{Dir.pwd}': #{command}"
      end

      if($SimulateTasks)
        return
      end

      result = system(command)
      if(result != true)
        raise message
      end
    end
  
    # Clone an arbitrary object
    # Returns nil for nil and the orginal for symbols.
    def Clone(original)
      if(original.class == Symbol or original == false or original == true)
        return original
      end
      
      if(original.class == Array)
	return CloneArray(original)
      end
    
      if(original != nil)
        return original.clone()
      end
    
      return nil
    end
    
    def CloneArray(original)
      copy = []
      
      original.each() do |item|
	copy.push(Clone(item))
      end
      
      return copy
    end

    # Get the name of the class of the object.
    # Return the pure class name without any module.
    def GetClassName(object)
      nameParts = object.class.name.split("::")
      return nameParts[nameParts.length-1]
    end

    # Get a UUID with surrounding brackets.
    # Example: {D9F40C8D-144E-4F80-8C74-1B1AAD84ADFB}
    def GetUUID
      return "\{#{UUIDTools::UUID.random_create().to_s}\}"
    end
    
    # Add a description to the tasks.
    # [docuTask] The task to build the docu of the project.
    # [packetInstallTask] The task that will install the packets for ubuntu OS needed for the project.
    # [createVSSolutionTask] The task that will create the VisualStudio solution for this project.
    # [cleanVSSolutionTask] The task that will delete the VisualStudio solution for this project.
    # [gccBuildTask] The task that will build this project with the gcc compiler
    def DescribeTasks(paramBag)
      docuTask = paramBag[:docuTask]
      if(docuTask)
        Rake::Task[docuTask].comment = "Build the documentation for the project"
      end
      
      packetInstallTask = paramBag[:packetInstallTask]
      if(packetInstallTask)
        Rake::Task[packetInstallTask].comment = "Install the ubuntu packets needed for this project"
      end
      
      createVSSolutionTask = paramBag[:createVSSolutionTask]
      if(createVSSolutionTask)
        Rake::Task[createVSSolutionTask].comment = "Build the Visual Studio solution for this project"
      end
      
      cleanVSSolutionTask = paramBag[:cleanVSSolutionTask]
      if(cleanVSSolutionTask)
        Rake::Task[cleanVSSolutionTask].comment = "Delete the Visual Studio solution for this project"
      end
      
      gccBuildTask = paramBag[:gccBuildTask]
      if(gccBuildTask)
        Rake::Task[gccBuildTask].comment = "Build the project with the gcc"
      end      
    end
    
    # Generate a name for a task based on different criteria.
    # [projectName] The name of the project.
    # [configuration] The name of the configuration.
    # [type] A string describing the type of task.
    # [noid] Do not append a random uuid (default = false).
    def GenerateTaskName(paramBag)
      projectName = (paramBag[:projectName] or nil)
      configuration = (paramBag[:configuration] or nil)
      type = (paramBag[:type] or nil)
      noid = (paramBag[:noid] or false)
      
      if(noid)
        uuid = nil
      else
        uuid = GetUUID()        
      end
      
      taskNameParts = []
      
      if(projectName)
	taskNameParts.push( projectName )
      end
      if(configuration)
	taskNameParts.push( configuration )
      end
      if(type)
	taskNameParts.push( type )
      end
      if(uuid)
	taskNameParts.push( uuid )
      end
      
      return taskNameParts.join("_")
    end
  end
end