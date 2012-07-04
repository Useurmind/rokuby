module Rokuby
  # A module containing functionality that is needed in many of the processor of
  # a visual studio project builder.
  module VsProjectProcessorUtility
    
    def ProjectInstance
      @projectInstance
    end
    
    def ProjectDescription
      @projectDescription
    end
    
    def ProjectConfigurations
      @projectConfigurations
    end
    
    def VsProjectInstance
      @vsProjectInstance
    end
    
    def VsProjectDescription
      @vsProjectDescription
    end
    
    def VsProjectConfigurations
      @vsProjectConfigurations
    end
    
    def VsProjects
      @vsProjects
    end
    
    def VsProjectUsages
      @vsProjectUsages
    end
    
    def PassthroughDefines
      @passthroughDefines
    end
    
    def _InitProc      
      @projectInstance = nil
      @projectDescription = nil
      @projectConfigurations = []
      @vsProjectInstance = nil
      @vsProjectDescription = VsProjectDescription.new()
      @vsProjectConfigurations = []
      @vsProjects = []
      @vsProjectUsages = []
      @passthroughDefines = []
      
      _RegisterInputTypes()
    end
    
    # Register the known input types for such a processor.
    def _RegisterInputTypes
      @knownInputClasses.push(Rokuby::ProjectDescription)
      @knownInputClasses.push(Rokuby::ProjectConfiguration)
      @knownInputClasses.push(Rokuby::ProjectInstance)
      @knownInputClasses.push(Rokuby::VsProjectDescription)
      @knownInputClasses.push(Rokuby::VsProjectConfiguration)
      @knownInputClasses.push(Rokuby::VsProjectInstance)
      @knownInputClasses.push(Rokuby::VsProject)
      @knownInputClasses.push(Rokuby::VsProjectUsage)
      @knownInputClasses.push(Rokuby::PassthroughDefines)
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
        elsif(input.is_a?(Rokuby::VsProjectInstance))
          @vsProjectInstance = input
        elsif(input.is_a?(Rokuby::VsProjectDescription))
          @vsProjectDescription = input
        elsif(input.is_a?(Rokuby::VsProjectConfiguration))
          @vsProjectConfigurations.push(input)
        elsif(input.is_a?(Rokuby::VsProject))
          @vsProjects.push(input)
        elsif(input.is_a?(Rokuby::VsProjectUsage))
          @vsProjectUsages.push(input)
        elsif(input.is_a?(Rokuby::PassthroughDefines))
          @passthroughDefines.push(input)
        end
      end
    end
    
    def _ForwardOutputs
      _AddOutput(@projectInstance)
      _AddOutput(@projectDescription)
      _AddOutput(@projectConfigurations)
      _AddOutput(@vsProjectInstance)
      _AddOutput(@vsProjectDescription)
      _AddOutput(@vsProjectConfigurations)
      _AddOutput(@vsProjects)
      _AddOutput(@vsProjectUsages)
      _AddOutput(@passthroughDefines)
    end
    
    def _AddOutput(output)
      if(output != nil)
        if(output.class == Array)
          @outputs.concat(output)
        else
          @outputs.push(output)
        end        
      end
    end
    
    def _GetProjectUsage(guid)
      matchingUsage = nil
      @vsProjectUsages.each() do |projUsage|
        if(projUsage.Guid == guid)
          matchingUsage = projUsage
          break
        end
      end
      return matchingUsage
    end
  end
end
