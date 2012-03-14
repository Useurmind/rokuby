module RakeBuilder
  # This class finds all necessary parts for a project instance that is given
  # through a project specification.
  # Allowed inputs are ProjectSpecifications, SourceUnitSpecifications and
  # LibrarySpecifications.
  # Output is one ProjectInstance that contains all the gathered information.
  class ProjectFinder < Processor
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::ProjectSpecification)
      @knownInputClasses.push(RakeBuilder::SourceUnitSpecification)
      @knownInputClasses.push(RakeBuilder::LibrarySpecification)
    end
    
    def _ProcessInputs
      #puts "processing inputs #{@inputs} in ProjectFinder"
      
      sourceUnitSpecs = []
      librarySpecs = []
      
      projectInstance = ProjectInstance.new()
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::ProjectSpecification))
          sourceUnitSpecs.concat(input.SourceSpecs)
          librarySpecs.concat(input.LibrarySpecs)
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
      #puts "Processing source units #{suSpecs}"
      suFinder = SourceUnitFinder.new(@ProjectFile)
      
      suFinder.AddInput(suSpecs)
      suFinder.Process()
      
      return suFinder.Outputs()
    end
    
    def _ProcessLibraries(libSpecs)
      #puts "Processing libraries units #{libSpecs}"
      
      libFinder = LibraryFinder.new()
      
      libFinder.AddInput(libSpecs)
      libFinder.Process()
      
      return libFinder.Outputs()
    end
  end
end
