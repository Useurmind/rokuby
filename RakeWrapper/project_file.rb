module RakeBuilder
  class ProjectFile
    include Rake::TaskManager
    
    # Project path to the project file.
    # The relativ path component of this value must be relative to the topmost project files folder.
    attr_accessor :Path
    
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
    end
    
    def to_s
      val = "Project File '#{@Path}':\n"
      val += "Defined tasks: #{@tasks}\n"
      val += "Included projects: #{@ProjectFileIncludes}\n"
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
      @tasks[task_name.to_s] ||= task_class.new(task_name, Rake.application)
    end
  end
end
