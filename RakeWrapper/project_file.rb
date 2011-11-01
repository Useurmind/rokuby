module RakeBuilder
  class ProjectFile
    include Rake::TaskManager
    include Rake::DSL
    
    # Project path to the project file.
    # The relativ path component of this value must be relative to the topmost project files folder.
    attr_reader :Path
    
    # A rake filelist of patterns that should be included in the clean task.
    attr_reader :CleanList
    
    # A rake filelist of patterns that should be included in the clobber task.
    attr_reader :ClobberList
    
    def Path=(value)
      @Path = value.MakeRelativeTo(Rake.application.TopmostProjectFile.DirectoryPath().MakeAbsolute())
      
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
      @CleanList = Rake::FileList["**/*~", "**/*.bak", "**/core"]
      @ClobberList = Rake::FileList.new
    end
    
    def to_s
      val = "Project File '#{@Path}':\n"
      val += "Defined tasks: #{@tasks}\n"
      val += "Included projects: #{@ProjectFileIncludes}\n"
    end
    
    # get a list that describes all tasks in this proect file
    def GetTaskDescriptions(width, maxColumn)
      val = ""
      displayable_tasks = tasks.select { |t|
        t.comment && t.name =~ Rake.application.options.show_task_pattern
      }
      
      displayable_tasks.each do |t|
        val += sprintf "  #{Rake.application.name} %-#{width}s  # %s\n",
          t.name_with_args, maxColumn ? truncate(t.comment, maxColumn) : t.comment
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
      task_name = task_name.to_s
      self.lookup(task_name, scopes) or
        enhance_with_matching_rule(task_name) or
        synthesize_file_task(task_name)
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
        @CleanList.each { |fn| rm_r fn rescue nil }
      end
      task :clobber => [:clean] do 
        @ClobberList.each { |fn| rm_r fn rescue nil }
      end
    end
  end
end
