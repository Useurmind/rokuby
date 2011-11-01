module RakeBuilder

  ######################################################################
  # Rake main application object.  When invoking +rake+ from the
  # command line, a Rake::Application object is created and run.
  #
  class Application < Rake::Application    
    
      attr_reader :TopmostProjectFile
    
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
    
      # This is implemented to forward the last description to the currently loaded file.
      def last_description=(value)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.last_description = value
      end
    
      def initialize
        puts "Initializing Rake Builder Application"
        super
        @rakefiles = DEFAULT_RAKEFILES
        @ProjectFileLoader = RakeBuilder::ProjectFileLoader.new
        @name = "RakeBuilder"
      end
    
      def LoadProjectFile(path)
        @TopmostProjectFile = ProjectPath.new(path)
        @ProjectFileLoader.load(path)
      end
      
      ##########################################################################################
      # Interface used to run the application
      # This is what is used when running the RakeBuilder and gathering all the project files
      # and tasks.
      # It also executes the task that was given on the command line
      
      # Display the error message that caused the exception.
      def display_error_message(ex)
        super
        $stderr.puts self.to_s()
      end
      
      # Display the tasks and comments.
      def display_tasks_and_comments
        puts "Displaying tasks... \n"
        puts
        if(options.show_tasks == :tasks)
          # Get the maximum width of all task names
          all_displayable_tasks = tasks.select { |t|
            t.comment && t.name =~ options.show_task_pattern
          }
          
          width = all_displayable_tasks.collect { |t| t.name_with_args.length }.max || 10
          max_column = truncate_output? ? terminal_width - name.size - width - 7 : nil
          
          @ProjectFileLoader.LoadedProjectFiles.each do |path, projectFile|            
            puts "Task in project file: '#{projectFile.Path().RelativePath}'\n"
            puts projectFile.GetTaskDescriptions(width, max_column)
          end
        else
          super
        end
      end
      
      # This is changed because the clean syntax has changed.
      # There is now one clean task for each project file that can be executed separately.
      # Calling clean/clobber without extra information will clean all project files.
      def invoke_task(task_string)
        name, args = parse_task_string(task_string)
        
        if(name == "clean" or name == "clobber")          
          if(args.length > 0)
            # Execute only the clean targets mentioned in the arguments
            args.each do |arg|
              path = ProjectPath.new(arg)
              projectFile = @ProjectFileLoader.LoadedProjectFiles[path.RelativePath]
              task = projectFile[name]
              task.invoke(*args)
            end
          else
            # Execute all clean targets
            @ProjectFileLoader.LoadedProjectFiles.each do |path, projectFile|  
              task = projectFile[name]
              task.invoke(*args)
            end
          end
        else
          super(task_string)
        end
      end
      
      ##########################################################################################
      # New dsl interface introduced by the RakeBuilder module
      
      # This is called when an additional file is inculded by a project file.
      # It adds the file that should be imported to the currently loaded project file.
      def AddProjectImport(path)
        projectPath = ProjectPath.new(path)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.ProjectFileIncludes.push(projectPath)
      end
      
      # Include a file expression into the list of clean targets of the current project file.
      def IncludeCleanTargets(*includes)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.CleanList.include(includes)
      end
      
      # Include a file expression into the list of clobber targets of the current project file.
      def IncludeClobberTargets(*includes)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.ClobberList.include(includes)
      end
    
      ##########################################################################################
      # Interface used for the definition and lookup of task/rules etc. , mostly used in the dsl
    
      # Clear the task list.  This cause rake to immediately forget all the
      # tasks that have been assigned.  (Normally used in the unit tests.)
      def clear
        @ProjectFileLoader.LoadedProjectFiles.each do |path, projectFile|
          projectFile.clear()
        end
      end

      # List of all defined tasks.
      def tasks
        tasks = []
        @ProjectFileLoader.LoadedProjectFiles.each do |path, projectFile|
          tasks.concat(projectFile.tasks)
        end
        return tasks
      end

      # Return a task with the given name.  If the task is not currently
      # known, try to synthesize one from the defined rules.  If no rules are
      # found, but an existing file matches the task name, assume it is a file
      # task with no dependencies or actions.
      def [](task_name, scopes=nil)
        task = nil
        @ProjectFileLoader.LoadedProjectFiles.each do |path, projectFile|
          task = projectFile[task_name, scopes]
          if(task != nil)
            break
          end
        end
        if(!task)
          fail "Don't know how to build task '#{task_name}'"
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
        @ProjectFileLoader.LoadedProjectFiles.each do |path, projectFile|
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
      def define_task(task_class, *args, &block)
        @ProjectFileLoader.CurrentlyLoadedProjectFile.define_task(task_class, *args, &block)
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
      
      def to_s
        val = "RakeBuilder Application Status:\n"
        val += "===============================================\n"
        val += @ProjectFileLoader.to_s
        val += "===============================================\n"
      end
  end
end

