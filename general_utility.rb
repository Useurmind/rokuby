module GeneralUtility
  # Execute a system call with the given command.
  # Ob failure print the message if print is set to true.
  def SystemWithFail(command, message="", print=true)
    if(print)
      puts command
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
end