module RakeBuilder
  # This class creates project and filter file for a given project and produces a
  # VSProject instance that can be used in other projects.
  # This builder works like a normal builder but additionally accepts a visual studio
  # project description, one visual studio instance and several configurations.
  # The configurations are associated with the project configurations by means of the
  # platform they are defined for. Make sure that there is at most one visual studio and normal
  # project configuration for each platform.
  # Output of this processor is a VSProject instance that represents the created project.
  class VSProjectBuilder < ProjectBuilder
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @processChain = ProcessChain.new()
      
      @projectPreprocessor = VSProjectPreprocessor.new()
      @projectCreator = VSProjectCreator.new()
      @fileWriter = VSProjectFilesWriter.new()
      
      @processChain.Connect(@projectPreprocessor, @fileWriter)
      @processChain.Connect(@projectPreprocessor, @projectCreator)      
      
      @vsProjectDescription = VSProjectDescription.new()
      @vsProjectInstance = VSProjectInstance.new()
      @vsProjectConfigurations = []
      
      @knownInputClasses.push(RakeBuilder::VSProjectDescription)
      @knownInputClasses.push(RakeBuilder::VSProjectInstance)
      @knownInputClasses.push(RakeBuilder::VSProjectConfiguration)
    end
    
    def _BuildProject
      @processChain.AddInput(@projectPreprocessor, @inputs)
      
      @processChain.AddInput(@fileWriter, @vsProjectInstance)
      @processChain.AddInput(@fileWriter, @projectInstance)
      
      @processChain.AddInput(@projectCreator, @vsProjectInstance)
      @processChain.AddInput(@projectCreator, @projectInstance)
      
      @processChain.Process()
      
      @outputs = @projectCreator.Outputs
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
