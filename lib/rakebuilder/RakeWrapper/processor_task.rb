module Rake
  # A task from which processors are derived.
  # Processors are tasks and this task channels the invocation and execution into
  # execution of the processor.
  # On invocation:
  # - first the task and all it's dependecies are executed (this includes the input processors)
  # - second the processor will process its input values
  class ProcessorTask < Task    
    # This will execute the processor which in turn invokes the old invoke function
    # of the task.
    def invoke_with_call_chain(task_args, invocation_chain)
      #puts "in invoke of #{self.class}"
      Process(task_args, invocation_chain)
    end
    
    def InvokePrerequisites(task_args, invocation_chain)
      new_chain = InvocationChain.append(self, invocation_chain)
      @lock.synchronize do
        if application.options.trace
          $stderr.puts "** Invoke #{name} #{format_trace_flags}"
        end
        return if @already_invoked
        @already_invoked = true
        invoke_prerequisites(task_args, new_chain)
      end
    rescue Exception => ex
      add_chain_to(ex, new_chain)
      raise ex
    end
    
    # Execute the task and all its actions
    def Execute(task_args)
      execute(task_args) if needed?  # taken from invoke_with_call_chain
    end
    
    # Is this processor task embedded into the task hierarchy or not.
    def InTaskHierarchy?()
      return @ProjectFile != nil
    end
  end
end
