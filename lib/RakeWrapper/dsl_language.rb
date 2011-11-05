module Rake
  
  # Just extend the basic rake dsl.
  module DSL
  
    # Incude a project file from a subfolder
    def import(path)
      Rake.application.AddProjectImport(path)
    end
    
    def taskDescriptor(task)
      RakeBuilder::TaskDescriptor.new(task)
    end
  
    def clean(*includes)
      Rake.application.IncludeCleanTargets(includes)
    end
  
    def clobber(*includes)
      Rake.application.IncludeClobberTargets(includes)
    end
  
  end
  
end
