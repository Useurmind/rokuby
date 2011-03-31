module GeneralUtility
  def SystemWithFail(command, message="", print=true)
    if(print)
      puts command
    end
    result = system(command)
    if(result != true)
      abort message
    end
  end
end