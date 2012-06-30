module Rokuby
  module GppProjectProcessorUtility

    def _InitProc
      @projectInstance = nil
      @projectDescription = nil
      @projectConfigurations = []
      @gppProjectDescription = VsProjectDescription.new()
      @gppProjectConfigurations = []
      @gppProjects = []
      
      _RegisterInputTypes()
    end

    # Register the known input types for such a processor.
    def _RegisterInputTypes
      @knownInputClasses.push(Rokuby::ProjectDescription)
      @knownInputClasses.push(Rokuby::ProjectConfiguration)
      @knownInputClasses.push(Rokuby::ProjectInstance)
      @knownInputClasses.push(Rokuby::GppProjectDescription)
      @knownInputClasses.push(Rokuby::GppProjectConfiguration)
      @knownInputClasses.push(Rokuby::GppProject)
    end

    # Sort the processor inputs by their class type.
    def _SortInputs
      @inputs.each() do |input|
        if(input.is_a?(Rokuby::ProjectInstance))
          @projectInstance = input
        elsif(input.is_a?(Rokuby::ProjectDescription))
          @projectDescription = input
        elsif(input.is_a?(Rokuby::ProjectConfiguration))
          @projectConfigurations.push(input)
        elsif(input.is_a?(Rokuby::GppProjectDescription))
          @gppProjectDescription = input
        elsif(input.is_a?(Rokuby::GppProjectConfiguration))
          @gppProjectConfigurations.push(input)
        elsif(input.is_a?(Rokuby::GppProject))
          @gppProjects.push(input)
        end
      end
    end

    def _GetGppProjectConf(platform)
      @gppProjectConfigurations.each() do |gppConf|
        if(gppConf.Platform <= platform)
          return gppConf
        end
      end
      return nil
    end
    
    def _ForwardOutputs
      @outputs.push(@projectInstance)
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@gppProjectDescription)
      @outputs.concat(@gppProjectConfigurations)
      @outputs.concat(@gppProjects)
    end
  end
end
