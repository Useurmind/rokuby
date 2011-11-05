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
        @ProjectFileLoader.CurrentlyLoadedProjectFile().last_description = value
      end
    
      def initialize
        puts "Initializing Rake Builder Application"
        super
        @rakefiles = DEFAULT_RAKEFILES
        @ProjectFileLoader = RakeBuilder::ProjectFileLoader.new
        @name = "RakeBuilder"
      end
      
      def init(app_name=@name)
        super(app_name)
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
      
      # Run the top level tasks of a Rake application.
      def top_level
        if(options.show_status == true)
          puts to_s
        else
          super
        end
      end
      
      # A list of all the standard options used in rake, suitable for
      # passing to OptionParser.
      def standard_rake_options
        super().concat([
          ['--status', "Print the status of the RakeBuilder.",
            lambda { |value|
              options.show_status = true
            }
          ]
        ])
      end
      
      # Display the error message that caused the exception.
      def display_error_message(ex)
        $stderr.puts self.to_s()
        super(ex)        
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
          
          @ProjectFileLoader.LoadedProjectFiles().each do |projectFile|            
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
        taskPath, args = parse_task_string(task_string)
        
        projectPath, name = parse_task_path(taskPath)
          
        if(projectPath == nil and (name == "clean" or name == "clobber"))
          # Execute all clean targets
          puts "Cleaning all projects..."
          @ProjectFileLoader.LoadedProjectFiles().each do |projFile|  
            task = projFile[name]
            task.invoke(*args)
          end
        else
          task = self[taskPath]
          task.invoke(*args)
        end
      end
      
      # Split the task path in a string describing the file where the task is defined
      # and its name.
      def parse_task_path(taskPath)
        projectPath = nil
        name = nil
        match = taskPath.match("^([^:]*):(.*)$")
        if(match)
          projectPath = ProjectPath.new(match[1])
          name = match[2]
        else
          name = taskPath
        end
        
        return projectPath, name
      end
      
      ##########################################################################################
      # New dsl interface introduced by the RakeBuilder module
      
      # This is called when an additional file is inculded by a project file.
      # It will load the project file asap to make its values available in the
      # loading project file and above.
      def AddProjectImport(path)
        projectPath = ProjectPath.new(path)
        @ProjectFileLoader.LoadProjectFile(projectPath)
      end
      
      # Include a file expression into the list of clean targets of the current project file.
      def IncludeCleanTargets(*includes)
        @ProjectFileLoader.CurrentlyLoadedProjectFile().CleanList.include(includes)
      end
      
      # Include a file expression into the list of clobber targets of the current project file.
      def IncludeClobberTargets(*includes)
        @ProjectFileLoader.CurrentlyLoadedProjectFile().ClobberList.include(includes)
      end
    
      ##########################################################################################
      # Interface used for the definition and lookup of task/rules etc. , mostly used in the dsl
    
      # Clear the task list.  This cause rake to immediately forget all the
      # tasks that have been assigned.  (Normally used in the unit tests.)
      def clear
        @ProjectFileLoader.LoadedProjectFiles().each do |projectFile|
          projectFile.clear()
        end
      end

      # List of all defined tasks.
      def tasks
        tasks = []
        @ProjectFileLoader.LoadedProjectFiles().each do |projectFile|
          tasks.concat(projectFile.tasks)
        end
        return tasks
      end

      # Return a task with the given name.  If the task is not currently
      # known, try to synthesize one from the defined rules.  If no rules are
      # found, but an existing file matches the task name, assume it is a file
      # task with no dependencies or actions.
      def [](taskPath, scopes=nil)
        task = nil
        
        projectPath, name = parse_task_path(taskPath)
        
        if(projectPath != nil)
          # return the project file specific task
          projectFile = @ProjectFileLoader.LoadedProjectFile(projectPath.RelativePath)
          if(!projectFile)
            fail "Don't know project file '#{projectPath}'"
          end
          task = projectFile[name, scopes]
          if(!task)
            fail "Don't know task '#{name}' in project file '#{projectPath}'"
          end
        else
          # return the first task that is found in any project file
          @ProjectFileLoader.LoadedProjectFiles().each do |projFile|
            task = projFile[name, scopes]
            if(task != nil)
              break
            end
          end
          if(!task)
            fail "Don't know how to build task '#{name}'"
          end
        end
        return task
      end
      
      # Lookup a task, using scope and the scope hints in the task name.
      # This method performs straight lookups without trying to
      # synthesize file tasks or rules.  Special scope names (e.g. '^')
      # are recognized.  If no scope argument is supplied, use the
      # current scope.  Return nil if the task cannot be found.
      def lookup(taskPath, initial_scope=nil)
        task = nil
        
        projectPath, name = parse_task_path(taskPath)
        
        if(projectPath != nil)
          # return the project file specific task
          projectFile = @ProjectFileLoader.LoadedProjectFile(projectPath.RelativePath)
          if(!projectFile)
            return task
          end
          task = projectFile.lookup(name, initial_scope)
        else
          # return the first task that is found in any project file
          @ProjectFileLoader.LoadedProjectFiles().each do |projFile|
            task = projFile.lookup(name, initial_scope)
            if(task != nil)
              break
            end
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
        @ProjectFileLoader.CurrentlyLoadedProjectFile().define_task(task_class, *args, &block)
      end

      # Define a rule for synthesizing tasks.
      def create_rule(*args, &block)
        @ProjectFileLoader.CurrentlyLoadedProjectFile().create_rule(*args, &block)
      end

      # Apply the scope to the task name according to the rules for
      # this kind of task.  Generic tasks will accept the scope as
      # part of the name.
      def scope_name(scope, task_name)
        (scope + [task_name]).join(':')
      end
      
      def to_s
        val = "\nRakeBuilder Application Status:\n"
        val += "===============================================\n"
        val += @ProjectFileLoader.to_s
        val += "===============================================\n\n"
      end
  end
end

