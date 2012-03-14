module RakeBuilder
  # This processor processes VSProjectSpecifications to produce corresponding instances.
  class VSProjectFinder < Processor
     def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::VSProjectSpecification)
    end
    
    def _ProcessInputs
      resourceUnitSpecs = []
      
      vsProjectInstance = VSProjectInstance.new()
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::VSProjectSpecification))
          resourceUnitSpecs.concat(input.ResourceFileSpec)
        end
      end
      
      vsProjectInstance.ResourceFileSet.concat(_ProcessResourceUnits(resourceUnitSpecs))
      
      @outputs = [vsProjectInstance]
    end
    
    def _ProcessSourceUnits(suSpecs)
      suFinder = SourceUnitFinder.new()
      
      suFinder.AddInput(suSpecs)
      suFinder.Process()
      
      return suFinder.Outputs()
    end
    
    def _ProcessLibraries(libSpecs)
      libFinder = LibraryFinder.new()
      
      libFinder.AddInput(libSpecs)
      libFinder.Process()
      
      return libFinder.Outputs()
    end
  end
end
