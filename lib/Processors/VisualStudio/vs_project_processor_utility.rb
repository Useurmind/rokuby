module RakeBuilder
  # A module containing functionality that is needed in many of the processor of
  # a visual studio project builder.
  module VSProjectProcessorUtility
    
    # Register the known input types for such a processor.
    def _RegisterInputTypes
      @knownInputClasses.push(RakeBuilder::ProjectDescription)
      @knownInputClasses.push(RakeBuilder::ProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::ProjectInstance)
      @knownInputClasses.push(RakeBuilder::VSProjectDescription)
      @knownInputClasses.push(RakeBuilder::VSProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::VSProjectInstance)
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
        elsif(input.is_a?(RakeBuilder::VSProjectInstance))
          @vsProjectInstance = input
        elsif(input.is_a?(RakeBuilder::VSProjectDescription))
          @vsProjectDescription = input
        elsif(input.is_a?(RakeBuilder::VSProjectConfiguration))
          @vsProjectConfigurations.push(input)
        end
      end
    end
  end
end
