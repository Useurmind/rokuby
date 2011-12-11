module Rake
  
  # Just extend the basic rake dsl.
  module DSL
  
    # Incude a project file from a subfolder.
    # The path is given in the form "subfolder/projectfile_name".
    def import(path)
      Rake.application.AddProjectImport(path)
    end
    
    # For debugging purposes.
    # Prints useful information concerning the task.
    def taskDescriptor(task)
      RakeBuilder::TaskDescriptor.new(task)
    end
  
    # Add files to the clean target of this project file.
    def clean(*includes)
      Rake.application.IncludeCleanTargets(includes)
    end
  
    # Add files to the clobber target of this project file.
    def clobber(*includes)
      Rake.application.IncludeClobberTargets(includes)
    end
  
  end
  
end
