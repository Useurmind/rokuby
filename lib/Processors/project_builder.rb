module RakeBuilder
  # Project builders are processors that are responsible for building single
  # projects.
  # A project builder takes one project description, one project instance and
  # several configurations and generates a project based on that.
  # They are merely a base class for building complete project builder classes
  # for specific types of projects.
  class ProjectBuilder < Processor
    def initialize(name)
      super(name)
      
      @projectInstance = nil
      @projectDescription = nil
      @projectConfigurations = []
      
      @knownInputClasses.push(RakeBuilder::ProjectInstance)     # the input of all project instances is used to find the right sources
      @knownInputClasses.push(RakeBuilder::ProjectDescription)  # meta information for the project the last one is the one used
      @knownInputClasses.push(RakeBuilder::ProjectConfiguration)  # meta information for the project the last one is the one used
    end
    
    def _CheckInputs()
      if(@projectDescription == nil)
        raise "No project description given in #{self.class.name}"
      end
      
      if(@projectInstance == nil)
        raise "No project instance given in #{self.class.name}"
      end
      
      if(@projectConfigurations.length == 0)
        raise "No project configuration given in #{self.class.name}"
      end
    end
    
    def _SortInput(input)
      if(input.is_a?(RakeBuilder::ProjectInstance))
        @projectInstance = input
      elsif(input.is_a?(RakeBuilder::ProjectDescription))
        @projectDescription = input
      elsif(input.is_a?(RakeBuilder::ProjectConfiguration))
        @projectConfigurations.push(input)
      end
    end
    
    def _ProcessInputs
      @inputs.each() do |input|
        _SortInput(input)
      end
      _CheckInputs()
      # Do stuff to build project...
      _BuildProject()
    end
    
    # Overwrite this in actual implementation
    def _BuildProject
      raise "_BuildProject not implemented in #{self.class.name}"
    end
    
    def _GetProjectConfiguration(platform)
      @projectConfigurations.each() do |conf|
        if(conf.Platform == platform)
          return conf
        end
      end
      return nil
    end
  end
end
