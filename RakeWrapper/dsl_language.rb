module Rake
  
  # Just extend the basic rake dsl.
  module DSL
  
    # Incude a project file from a subfolder
    def project(path)
      Rake.application.AddProjectImport(path)
    end
  
  end
  
end
