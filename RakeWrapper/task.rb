module Rake
  # Overwrite some of the functionality provided by the rake task class
  class Task
    include RakeBuilder::PathUtility
    
    # The project file in which the task was defined.
    attr_reader :ProjectFile
    
    # Create a task named +task_name+ with no actions or prerequisites. Use
    # +enhance+ to add actions and prerequisites.
    alias initialize_old initialize
    def initialize(task_name, app, projectFile)
      initialize_old(task_name, app)
      @ProjectFile = projectFile
    end
    
    # Execute the actions associated with this task.
    # Needs to be executed in the appropriate directory
    alias execute_old execute
    def execute(args=nil)
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        execute_old(args)
      end
    end
  end
end
