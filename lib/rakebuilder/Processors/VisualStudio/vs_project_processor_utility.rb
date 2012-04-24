module RakeBuilder
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
      @knownInputClasses.push(RakeBuilder::ProjectDescription)
      @knownInputClasses.push(RakeBuilder::ProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::ProjectInstance)
      @knownInputClasses.push(RakeBuilder::VsProjectDescription)
      @knownInputClasses.push(RakeBuilder::VsProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::VsProjectInstance)
      @knownInputClasses.push(RakeBuilder::VsProject)
      @knownInputClasses.push(RakeBuilder::VsProjectUsage)
      @knownInputClasses.push(RakeBuilder::PassthroughDefines)
    end
    
    # Sort the processor inputs by their class type.
    def _SortInputs
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::ProjectInstance))
          @projectInstance = input
        elsif(input.is_a?(RakeBuilder::ProjectDescription))
          @projectDescription = input
        elsif(input.is_a?(RakeBuilder::ProjectConfiguration))
          @projectConfigurations.push(input)
        elsif(input.is_a?(RakeBuilder::VsProjectInstance))
          @vsProjectInstance = input
        elsif(input.is_a?(RakeBuilder::VsProjectDescription))
          @vsProjectDescription = input
        elsif(input.is_a?(RakeBuilder::VsProjectConfiguration))
          @vsProjectConfigurations.push(input)
        elsif(input.is_a?(RakeBuilder::VsProject))
          @vsProjects.push(input)
        elsif(input.is_a?(RakeBuilder::VsProjectUsage))
          @vsProjectUsages.push(input)
        elsif(input.is_a?(RakeBuilder::PassthroughDefines))
          @passthroughDefines.push(input)
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
