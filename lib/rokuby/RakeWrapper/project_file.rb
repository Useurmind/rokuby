module Rokuby
  # Project files can be loaded by other project files.
  # Each project file spans a namespace in which its tasks are defined.
  # Additionally the task are guaranteed to be executed in the folder where
  # the project file is located.
  # Each project file has an own clean and clobber target that can be used.
  # Project file specific tasks are called by joining the project file path
  # which is relative to the topmost project file with the task name by a colon.
  # (e.g. "Test/ProjectFile.rb:Task1")
  class ProjectFile
    include Rake::TaskManager
    include Rake::DSL
    include InformationUnitManager
    include ProcessManager
    include TaskDescription
    include PathUtility
    #include DSL
    
    # @return [ProjectPath] The path to the project file, relative to the topmost project file folder.
    attr_reader :Path
    
    # @return [Rake::FileList] A list of patterns that should be included in the clean task.
    attr_reader :CleanList
    
    # @return [Rake::FileList] A list of patterns that should be included in the clobber task.
    attr_reader :ClobberList
    
    # Set the path of this project file.
    # @param [ProjectPath] value The new value for the project path (not required to have a specific relative part).
    def Path=(value)
      #puts "Setting path of project file to #{[value]}, absolute: #{value.absolute?()}"
      
      #puts "Making path value relative to topmost project file #{[Rake.application.TopmostProjectFile]}"
      
      @Path = value.MakeRelativeTo(Rake.application.TopmostProjectFile.DirectoryPath().MakeAbsolute())
      @ProcessCache = ProcessCache.new(@Path.DirectoryPath + ProjectPath.new(@Path.FileName(false) + ".cache"))
      
      #puts "Result of conversion: #{[@Path]}"
      
      
      @Namespace = ProjectNamespace.new()
      @Namespace.SetProjectPath(@Path)
    end
    
    # Project paths to project files that are included in this one.
    # These pathes are relative to the folder of this project file.
    attr_accessor :ProjectFileIncludes
    
    # The namespace for task and co. that this project file creates.
    attr_accessor :Namespace
    
    def initialize
      super
      @ProjectFileIncludes = []
      @CleanList = Rake::FileList["**/*~", "**/*.bak"]
      @ClobberList = Rake::FileList.new
      ResetTaskDescription(false)
    end
    
    def to_s
      val = "Project File '#{@Path}':\n"
      val += "Defined tasks: #{@tasks}\n"
      val += "Defined rules: #{@rules}\n"
      val += "Included projects: #{@ProjectFileIncludes}\n"      
    end
    
    def DisplayableTasks
      return tasks.select { |t|
        !t.IsTaskDescriptionEmpty?() && t.name =~ Rake.application.options.show_task_pattern
      }
    end
    
    def HasTasks()
      displayable_tasks = DisplayableTasks()
      
      return displayable_tasks.length != 0
    end
    
    # get a list that describes all tasks in this project file.
    def GetTaskDescriptions(width, maxColumn)
      val = ""
      #puts "tasks in projectfile: #{tasks}"
      displayable_tasks = DisplayableTasks()
      
      #puts "displayable tasks in projectfile: #{displayable_tasks}"
      
      displayable_tasks.each do |t|
        val += CreateTaskDescription(t, width, maxColumn)        
      end
      
      val += "\n"
      return val
    end
    
    def CreateTaskDescription(task, width, maxColumn)
      val = ""
      firstLine = true
      preCommentSize = Rake.application.name.length + 3 + task.name_with_args.length + 2
      preTaskNameSize = Rake.application.name.length + 3
      preTaskArgsSize = Rake.application.name.length + 4 + task.name.length
      
        
      #puts "Creating task description for task #{task}"
      
      #puts "Task description lines #{task.TaskDescriptions}"
      #puts "Arg description lines #{task.ArgDescriptions}"
        
      task.TaskDescriptions.each() do |taskDescr|
        lines = SplitStringToMultipleLines(taskDescr, maxColumn)
        
        #puts "adding lines to output: #{lines}"
        
        lines.each() do |line|
          if(firstLine)
            val += sprintf "  #{Rake.application.name} %s%-#{preCommentSize - preTaskNameSize - task.name_with_args.length}s# %s\n", task.name_with_args, " ", line
            firstLine = false
          else
            val += sprintf "%-#{preCommentSize}s# %s\n", " ", line
          end
        end        
      end
      
      task.ArgDescriptions.each() do |argName, argDescriptions|        
        firstLine = true
        argDescriptions.each() do |argDescr|
          lines = SplitStringToMultipleLines(argDescr, maxColumn)
        
          lines.each() do |line|
            if(firstLine)
              val += sprintf "%-#{preTaskArgsSize}s%s%-#{preCommentSize - preTaskArgsSize - argName.length}s# %s\n", " ", argName, " ", line
              firstLine = false
            else
              val += sprintf "%-#{preCommentSize}s# %s\n", " ", line
            end
          end
        end
      end
      val += "\n"
      
      #puts "task description for task #{task.name} is: #{val}"
      
      return val
    end
      
    def SplitStringToMultipleLines(s, maxColumn)
      words = s.split(" ")      
      lines = []
      
      #puts "words in split: #{words}"
      
      currentLine = ""
      words.each() do |word|
        #puts "currentLine: #{currentLine}"
        #puts "word: #{word}"
        #puts "lines: #{lines}"
        
        if(currentLine.length + word.length + 1 > maxColumn)
          if(currentLine != "")
            lines.push(currentLine)
          end
          currentLine = ""
        end
        
        if(currentLine == "")
          currentLine = word
        else
          currentLine = currentLine + " " + word
        end        
      end
      
      if(currentLine != "")
        lines.push(currentLine)
      end
      
      return lines
    end
    
    def truncate(string, width)
      if string.length <= width
        string
      else
        ( string[0, width-3] || "" ) + "..."
      end
    end
    
    ##########################################################
    # Overwritten TaskManager methods
    
    # Find a matching task for +task_name+.
    # Overwritten to not fail.
    def [](task_name, scopes=nil)
      #puts "Looking for task '#{task_name}' in project file '#{Path().to_s}'"
      task_name = task_name.to_s
      task = (self.lookup(task_name, scopes) or
              enhance_with_matching_rule(task_name) or
              synthesize_file_task(task_name))
      #puts "Found task '#{task != nil}'"
      return task
    end
    
    # Lookup a task.  Return an existing task if found, otherwise
    # create a task of the current type.
    # Overwritten to input application instead of self.
    def intern(task_class, task_name)
      @tasks[task_name.to_s] ||= task_class.new(task_name, Rake.application, self)
    end
    
    # Define the clean and clobber task for this project file.
    def DefineCleanTasks
      task :clean do
        @CleanList.uniq().each { |fn| rm_r fn rescue nil }
      end
      task :clobber => [:clean] do 
        @ClobberList.uniq().each { |fn| rm_r fn rescue nil }
      end
    end
    
    # Overwritten to return new more sophisticated description structure.
    def get_description(task)
      taskDescriptions = @TaskDescriptions
      argDescriptions = @ArgDescriptions
      ResetTaskDescription(false)
      return taskDescriptions, argDescriptions
    end
    
    alias synthesize_file_task_old synthesize_file_task
    def synthesize_file_task(task_name)
      val = nil
      ExecuteInPath(self.Path().DirectoryPath()) do
        val = synthesize_file_task_old(task_name)
      end
      return val
    end
  end
end
