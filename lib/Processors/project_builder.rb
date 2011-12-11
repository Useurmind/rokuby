module RakeBuilder
  # Project builders are processors that are responsible for building single
  # projects.
  # A project builder takes one project description, one project instance and
  # several configurations and generates a project based on that.
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
