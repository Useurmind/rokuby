module Rake
  # This task can be separately activated.
  # It is only needed if it was previously activated.
  # Used in conjunction with ProxyTask.
  class ConditionalTask < Task
    
    attr_accessor :Active
    attr_accessor :Arguments
    
    # Create a task named +task_name+ with no actions or prerequisites. Use
    # +enhance+ to add actions and prerequisites.
    alias initialize_old_conditionaltask initialize
    def initialize(task_name, app, projectFile)
      @Active = false
      @Arguments = []
      initialize_old_conditionaltask(task_name, app, projectFile) # this is the initialize of the overwritten task class
    end
    
    # Only needed if it is set to active.
    alias needed_old_conditionaltask? needed?
    def needed?
      if(!@Active)
        return false
      end
      return needed_old_conditionaltask?()
    end
    
    # use the proxied arguments as input arguments for this task
    alias invoke_old_conditionaltask invoke
    def invoke(*args)
      if(@Arguments.length > 0)
        invoke_old_conditionaltask(*(@Arguments))
      else
        invoke_old_conditionaltask(*args)
      end      
    end
    
  end
end
