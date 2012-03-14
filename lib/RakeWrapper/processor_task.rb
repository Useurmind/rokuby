module Rake
  # A task from which processors are derived.
  # Processors are tasks and this task channels the invocation and execution into
  # execution of the processor.
  # On invocation:
  # - first the task and all it's dependecies are executed (this includes the input processors)
  # - second the processor will process its input values
  class ProcessorTask < Task
    
    alias invoke_old invoke
    
    # This will execute the processor which in turn invokes the old invoke function
    # of the task.
    def invoke(*args)
      Process(args)
    end
    
    # This function is called by the processor to invoke this task.
    def InvokeFromProcessor(*args)
      invoke_old(args)
    end
    
    # Is this processor task embedded into the task hierarchy or not.
    def InTaskHierarchy?()
      return @ProjectFile != nil
    end
  end
end
