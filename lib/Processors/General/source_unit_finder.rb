module RakeBuilder
  # This class is responsible for finding the files described by a source unit
  # specification.
  # Input are SourceUnitSpecifications.
  # Output are SourceUnitInstances.
  class SourceUnitFinder < Processor
    include FindFile
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::SourceUnitSpecification)
    end
    
    def _ProcessInputs
      #puts "Processing inputs #{@inputs} in SourceUnitFinder"
      @inputs.each() do |suSpec|
        suInstance = SourceUnitInstance.new()
        suInstance.AddDefinesFrom(suSpec)
        
        suInstance.SourceFileSet = FindFile(suSpec.SourceFileSpec)
        suInstance.IncludeFileSet = FindFile(suSpec.IncludeFileSpec)
        
        #puts "SourceUnitInstance is #{suInstance}"
        
        @outputs.push(suInstance)
      end
    end
  end
end
