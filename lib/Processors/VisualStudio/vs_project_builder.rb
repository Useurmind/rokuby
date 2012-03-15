module RakeBuilder
  # This class creates project and filter file for a given project and produces a
  # VSProject instance that can be used in other projects.
  # This builder works like a normal builder but additionally accepts a visual studio
  # project description, one visual studio instance and several configurations.
  # The configurations are associated with the project configurations by means of the
  # platform they are defined for. Make sure that there is at most one visual studio and normal
  # project configuration for each platform.
  # Output of this processor is a VSProject instance that represents the created project.
  class VsProjectBuilder < ProjectBuilder
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @projectPreprocessor = DefineProc VsProjectPreprocessor, "#{@Name}_Pre"
      @projectCreator = DefineProc VsProjectCreator, "#{@Name}_Proj"
      @fileWriter = DefineProc VsProjectFilesWriter, "#{@Name}_Files"
      @vsProjectFinder = DefineProc VsProjectFinder, "#{@Name}_ProjFinder"
      
      Connect(:in, @fileWriter.to_s)
      Connect(:in, @vsProjectFinder.to_s, @fileWriter.to_s)
      Connect(:in, @projectPreprocessor.to_s)
      Connect(@projectPreprocessor.to_s, @fileWriter.to_s)
      Connect(@projectPreprocessor.to_s, @projectCreator.to_s)      
      Connect(@fileWriter.to_s, @projectCreator.to_s)
      Connect(@projectCreator.to_s, :out)
            
      @vsProjectDescription = VsProjectDescription.new()
      @vsProjectInstance = VsProjectInstance.new()
      @vsProjectConfigurations = []
      
      @knownInputClasses.push(RakeBuilder::VsProjectDescription)
      @knownInputClasses.push(RakeBuilder::VsProjectInstance)
      @knownInputClasses.push(RakeBuilder::VsProjectConfiguration)
    end
    
    def _ProcessInputs
    end
    
    def _CheckInputs
      super()
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
