module RakeBuilder
  # This class creates project and filter file for a given project.
  # This builder works like a normal builder but additionally accepts a visual studio
  # project description and one visual studio instance and several configurations.
  # The configurations are associated with the project configurations by means of the
  # platform they are defined for. Make sure that there is at most one visual studio and normal
  # project configuration for each platform.
  class VSProjectBuilder < ProjectBuilder
    def initialize(name)
      super(name)
      
      @vsProjectDescription = nil
      @vsProjectInstance = nil
      @vsProjectConfigurations = []
      
      @knownInputClasses.push(RakeBuilder::VSProjectDescription)
      @knownInputClasses.push(RakeBuilder::VSProjectInstance)
      @knownInputClasses.push(RakeBuilder::VSProjectConfiguration)
    end
    
    def _ProcessInputs
      @inputs.each() do |input|
        _SortInput(input)
      end
      
      _CheckInputs()
      
      
    end
    
    def _CheckInputs
      super()
      
      if(@vsProjectDescription == nil)
        raise "No project description given in #{self.class.name}"
      end
    end
    
    def _SortInput(input)
      if(input.is_a?(RakeBuilder::VSProjectConfiguration))
        @vsProjectConfigurations.push(input)
      elsif(input.is_a?(RakeBuilder::VSProjectInstance))
        @vsProjectInstance = input
      elsif(input.is_a?(RakeBuilder::VSProjectDescription))
        @vsProjectDescription = input
      else
        super(input)
      end
    end
    
    def _GetVsProjectConfiguration(platform)
      @vsProjectConfigurations.each() do |conf|
        if(conf.Platform == platform)
          return conf
        end
      end
      return nil
    end
  end
end
