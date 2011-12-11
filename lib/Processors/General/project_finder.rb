module RakeBuilder
  # This class finds all necessary parts for a project instance that is given
  # through a project specification.
  # Allowed inputs are ProjectSpecifications, SourceUnitSpecifications and
  # LibrarySpecifications.
  # Output is one ProjectInstance that contains all the gathered information.
  class ProjectFinder < Processor
    def initialize(name)
      super(name)
      
      @knownInputClasses.push(RakeBuilder::ProjectSpecification)
      @knownInputClasses.push(RakeBuilder::SourceUnitSpecification)
      @knownInputClasses.push(RakeBuilder::LibrarySpecification)
    end
    
    def _ProcessInputs
      sourceUnitSpecs = []
      librarySpecs = []
      
      projectInstance = ProjectInstance.new()
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::ProjectSpecification))
          sourceUnitSpecs.push(input.SourceSpecs)
          librarySpecs.push(input.LibrarySpecs)
          projectInstance.AddDefinesFrom(input)
        elsif(input.is_a?(RakeBuilder::SourceUnitSpecification))
          sourceUnitSpecs.push(input)
        elsif(input.is_a?(RakeBuilder::LibrarySpecification))
          librarySpecs.push(input)
        end
      end
      
      projectInstance.SourceUnits.concat(_ProcessSourceUnits(sourceUnitSpecs))
      projectInstance.Libraries.concat(_ProcessLibraries(librarySpecs))
      
      @outputs = [projectInstance]
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
