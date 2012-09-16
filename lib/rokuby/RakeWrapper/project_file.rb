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
    end
    
    def to_s
      val = "Project File '#{@Path}':\n"
      val += "Defined tasks: #{@tasks}\n"
      val += "Defined rules: #{@rules}\n"
      val += "Included projects: #{@ProjectFileIncludes}\n"      
    end
    
    def DisplayableTasks
      return tasks.select { |t|
        #puts "task: #{t.name} with comment #{t.comment}"
        t.comment && t.name =~ Rake.application.options.show_task_pattern
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
      
      nameSize = Rake.application.name.length + 4 + width
      sliceSize = maxColumn
      
      displayable_tasks.each do |t|
        
        i=0
        slices = []
        
        while(i<t.comment.length)
          sliceEnd = i+sliceSize
          if(sliceEnd >= t.comment.length)
            sliceEnd = t.comment.length - 1
          end
         #puts "slicing from #{i} to #{sliceEnd}"
          slices.push(t.comment.slice(i..sliceEnd))
          i = sliceEnd + 1          
        end
        
        val += sprintf "  #{Rake.application.name} %-#{width}s  # %s\n", t.name_with_args, slices[0]
          
        slices.delete_at(0)
        slices.each() do |slice|
          val += sprintf "%-#{nameSize}s # %s\n", " ", slice
        end
        val += "\n"
      end
      
      val += "\n"
      return val
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
  end
end
