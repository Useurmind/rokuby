module Rake
  # Overwrite some of the functionality provided by the rake task class
  class Task
    include RakeBuilder::TaskPathUtility
    include RakeBuilder::PathUtility
    
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
    end
    
    # Execute the actions associated with this task.
    # Needs to be executed in the appropriate directory
    alias execute_old_task execute
    def execute(args=nil)
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        execute_old_task(args)
      end
    end
    
    
    alias enhance_old_task enhance
    def enhance(deps=nil, &block)
      relativeDeps = nil
      if(deps)
        relativeDeps = deps.map() do |dep|
          MakeRelativeTo(dep, @ProjectFile)
        end
      end
      enhance_old_task(relativeDeps, &block)
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
  end
end
