module Rake
  # Overwrite some of the functionality provided by the rake task class
  class Task
    include Rokuby::PathUtility
    include Rokuby::TaskDescription
    
    # The project file in which the task was defined.
    attr_reader :ProjectFile
    
    # Create a task named +task_name+ with no actions or prerequisites. Use
    # +enhance+ to add actions and prerequisites.
    alias initialize_old_task initialize
    def initialize(task_name, app, projectFile)
      @ProjectFile = projectFile
      if(@ProjectFile)      
        initialize_old_task(task_name, app)
      end
      ResetTaskDescription(true)
    end
    
    # Execute the actions associated with this task.
    # Needs to be executed in the appropriate directory
    alias execute_old_task execute
    def execute(args=nil)
      #puts "Executing task with args #{args}"
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        execute_old_task(args)
      end
    end
    
    alias lookup_prerequisite_old_task lookup_prerequisite
    def lookup_prerequisite(prerequisite_name)
      application.CurrentTask = self
      #puts "Loading prerequisite '#{prerequisite_name}' in task '#{name}'"
      task = application[prerequisite_name, @scope]
      application.CurrentTask = nil
      return task
    end
    private :lookup_prerequisite
    
    alias add_description_old_task add_description
    def add_description(descriptions)
      AddTaskDescriptions(descriptions[0])
      AddTaskArgumentDescriptions(descriptions[1])
    end
    
    alias set_arg_names_old_task set_arg_names
    def set_arg_names(args)
      set_arg_names_old_task(args)
      @KnownArgNames = @arg_names
    end
  end
end
