module RakeBuilder

  ######################################################################
  # Rake main application object.  When invoking +rake+ from the
  # command line, a Rake::Application object is created and run.
  #
  class Application < Rake::Application
    
      DEFAULT_RAKEFILES = [
        'ProjectDefinition',
        'projectdefinition',
        'Projectdefinition',
        'projectDefinition',
        'ProjectDefinition.rb',
        'projectdefinition.rb',
        'Projectdefinition.rb',
        'projectDefinition.rb'
        ].freeze
    
      def initialize
        puts "Initializing Rake Builder Application"
        super
        @ProjectFileLoader = RakeBuilder::ProjectFileLoader.new
      end
      
      def LoadProjectFile(path)
        @ProjectFileLoader.load(path)
      end
    
      ##########################################################################################
      # Interface used to run the application
      # This is what is used when running the RakeBuilder and gathering all the project files
      # and tasks.
      # It also executes the task that was given on the command line
        
      def load_imports
        puts "Loading imports: " + @pending_imports
        super
      end
    
      ##########################################################################################
      # Interface used for the definition and lookup of task/rules etc. , mostly used in the dsl
    
      # Clear the task list.  This cause rake to immediately forget all the
      # tasks that have been assigned.  (Normally used in the unit tests.)
      def clear
        @ProjectFileLoader.LoadedProjectFiles.each do |projectFile|
          projectFile.clear()
        end
      end

      # List of all defined tasks.
      def tasks
        tasks = []
        @ProjectFileLoader.LoadedProjectFiles.each do |projectFile|
          tasks.concat(projectFile.tasks)
        end
        return tasks
      end

      # Return a task with the given name.  If the task is not currently
      # known, try to synthesize one from the defined rules.  If no rules are
      # found, but an existing file matches the task name, assume it is a file
      # task with no dependencies or actions.
      def [](task_name)
        task = nil
        @ProjectFileLoader.LoadedProjectFiles.each do |projectFile|
          task = projectFile[task_name]
          if(task != nil)
            break
          end
        end
        return task
      end
      
      # Lookup a task, using scope and the scope hints in the task name.
      # This method performs straight lookups without trying to
      # synthesize file tasks or rules.  Special scope names (e.g. '^')
      # are recognized.  If no scope argument is supplied, use the
      # current scope.  Return nil if the task cannot be found.
      def lookup(task_name, initial_scope=nil)
        task = nil
        @ProjectFileLoader.LoadedProjectFiles.each do |projectFile|
          task = projectFile.lookup(task_name, initial_scope)
          if(task != nil)
            break
          end
        end
        return task
      end

      # TRUE if the task name is already defined.
      def task_defined?(task_name)        
        lookup(task_name) != nil
      end

      # Define a task given +args+ and an option block.  If a rule with the
      # given name already exists, the prerequisites and actions are added to
      # the existing task.  Returns the defined task.
      def define_task(*args, &block)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.define_task(self, *args, &block)
      end

      # Define a rule for synthesizing tasks.
      def create_rule(*args, &block)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.create_rule(*args, &block)
      end

      # Apply the scope to the task name according to the rules for
      # this kind of task.  Generic tasks will accept the scope as
      # part of the name.
      def scope_name(scope, task_name)
        (scope + [task_name]).join(':')
      end
  end
end

