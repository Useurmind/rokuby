module RakeBuilder
  # This class is responsible for finding the files described by a source unit
  # specification.
  # Input are SourceUnitSpecifications.
  # Output are SourceUnitInstances.
  class SourceUnitFinder < Processor
    include FindFile
    
    def initialize(name)
      super(name)
      
      @knownInputClasses.push(RakeBuilder::SourceUnitSpecification)
    end
    
    def _ProcessInputs
      @inputs.each() do |suSpec|
        suInstance = SourceUnitInstance.new()
        suInstance.AddDefinesFrom(suSpec)
        
        suInstance.SourceFileSet = FindFile(suSpec.SourceFileSpec)
        suInstance.IncludeFileSet = FindFile(suSpec.IncludeFileSpec)
        
        @outputs.push(suInstance)
      end
    end
  end
end
