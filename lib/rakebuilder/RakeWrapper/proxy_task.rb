module Rake
  # This sort of task is used as a proxy for another task which is only executed
  # if this task was invoked beforehand.
  # Application of this is as follows:
  # - The task can be used as a call target to start the execution of a chain.
  # - The back task is embedded in the chain an can be enhanced during execution
  #   of the chain.
  # - When the chain comes to the point where the back task is enhanced, it is executed.
  class ProxyTask < Task
    attr_reader :BackTask
    
    def SetPreInvokeAction(&block)
      @PreInvokeAction = block
    end
    
    # Create a task named +task_name+ with no actions or prerequisites. Use
    # +enhance+ to add actions and prerequisites.
    alias initialize_old_proxytask initialize
    def initialize(task_name, app, projectFile)
      @BackTask = projectFile.define_task(ConditionalTask, task_name + "_BackTask")
      
      initialize_old_proxytask(task_name, app, projectFile) # this is the initialize of the overwritten task class
    end
    
    alias invoke_old_proxytask invoke
    def invoke(*args)
      @BackTask.Active = true
      if(@PreInvokeAction)
        @PreInvokeAction.call()
      end
      if(args.class == Array)
        @BackTask.Arguments = args
      end
      invoke_old_proxytask(*args)
    end
  end
end
