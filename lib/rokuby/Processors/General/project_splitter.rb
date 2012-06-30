module Rokuby
  # This class is used in a project finder to split the project specification
  # into source unit specifications and library specifications.
  class ProjectSplitter < Processor    
    def _InitProc
      @knownInputClasses.push(Rokuby::ProjectSpecification)
    end
    
    def _ProcessInputs(taskArgs=nil)
      @outputs = []
      @inputs.each() do |input|
        if(input.is_a?(Rokuby::ProjectSpecification))
          @outputs.concat(input.LibrarySpecs)
          @outputs.concat(input.SourceSpecs)
        end
      end
    end
  end
end
