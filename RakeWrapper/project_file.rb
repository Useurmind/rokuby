module RakeBuilder
  class ProjectFile
    include Rake::TaskManager
    
    # Project path to the project file.
    # The relativ path component of this value must be relative to the topmost project files folder.
    attr_accessor :Path
    
    def Path=(value)
      @Path = value.MakeRelativeTo(Rake.application.TopmostProjectFile)
      
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
    end
  end
end
