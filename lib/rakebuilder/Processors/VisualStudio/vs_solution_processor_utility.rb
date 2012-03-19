module RakeBuilder
  # A module containing functionality that is needed in many of the processor of
  # a visual studio project builder.
  module VsSolutionProcessorUtility
    
    def initialize(*args)
      super(*args)
      @vsSolutionDescription = nil
      @vsProjects = []
    end
    
    # Register the known input types for such a processor.
    def _RegisterInputTypes
      @knownInputClasses.push(RakeBuilder::VsSolutionDescription)
      @knownInputClasses.push(RakeBuilder::VsProject)
    end
    
    # Sort the processor inputs by their class type.
    def _SortInputs
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::VsSolutionDescription))
          @vsSolutionDescription = input
        elsif(input.is_a?(RakeBuilder::VsProject))
          @vsProjects.push(input)
        end
      end
    end
  end
end
