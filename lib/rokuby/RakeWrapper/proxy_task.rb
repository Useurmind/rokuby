module Rake
  # This sort of task is used as a proxy for another task which is only executed
  # if this task was invoked beforehand.
  # Additionally it can configured to modify the arguments given to it and forward
  # them to the prerequisite tasks.
  # Application of this is as follows:
  # - The task can be used as a call target to start the execution of a chain.
  # - The back task is embedded in the chain an can be enhanced during execution
  #   of the chain.
  # - When the chain comes to the point where the back task is enhanced, it is executed.
  class ProxyTask < Task
    
    def SetArgumentModificationAction(&block)
      @ArgumentModificationAction = block
    end
    
    # Create a task named +task_name+ with no actions or prerequisites. Use
    # +enhance+ to add actions and prerequisites.
    alias initialize_old_proxytask initialize
    def initialize(task_name, app, projectFile)
      @PreInvokeAction = nil
      @ArgumentModificationAction = nil
      
      initialize_old_proxytask(task_name, app, projectFile) # this is the initialize of the overwritten task class
    end
    
    alias invoke_old_proxytask invoke
    def invoke(*args)
      usedArgs = args
      
      if(@ArgumentModificationAction)
        usedArgs = @ArgumentModificationAction.call(args)
      end
      
      invoke_old_proxytask(*usedArgs)
    end
  end
end
