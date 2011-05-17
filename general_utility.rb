module RakeBuilder
  module GeneralUtility
    # Execute a system call with the given command.
    # Ob failure print the message if print is set to true.
    def SystemWithFail(command, message="", print=true)
      if(print)
        puts command
      end

      if($SimulateTasks)
        return
      end

      result = system(command)
      if(result != true)
        abort message
      end
    end
  
    # Clone an arbitrary object
    # Returns nil for nil and the orginal for symbols.
    def Clone(original)
      if(original.class == Symbol)
        return original
      end
    
      if(original != nil)
        return original.clone()
      end
    
      return nil
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
  end
end