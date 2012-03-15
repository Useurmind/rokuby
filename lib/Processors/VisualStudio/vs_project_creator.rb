module RakeBuilder
  # This processor is responsible for creating a VSProject instance, which can be used
  # in other projects.
  # Inputs are all the project objects that describe the project and output is a
  # VSProject instance that represents the created project.
  class VsProjectCreator < Processor
    include VsProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @Project = nil
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      
      @outputs = [@vsProjectDescription]
    end
  end
end
