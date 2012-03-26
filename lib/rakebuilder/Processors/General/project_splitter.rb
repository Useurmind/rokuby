module RakeBuilder
  # This class is used in a project finder to split the project specification
  # into source unit specifications and library specifications.
  class ProjectSplitter < Processor
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::ProjectSpecification)
    end
    
    def _ProcessInputs(taskArgs=nil)
      @outputs = []
      @inputs.each() do |input|
        @outputs.concat(input.LibrarySpecs)
        @outputs.concat(input.SourceSpecs)
      end
    end
  end
end
