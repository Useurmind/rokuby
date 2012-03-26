module RakeBuilder
  # This class is part of a project finder process chain.
  # It is used to fuse the libraries and source units into a final project instance.
  class ProjectJoiner < Processor
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::ProjectSpecification)
      @knownInputClasses.push(RakeBuilder::ProjectInstance)
      @knownInputClasses.push(RakeBuilder::SourceUnitInstance)
      @knownInputClasses.push(RakeBuilder::Library)
    end
    
    def _ProcessInputs(taskArgs=nil)      
      projectInstance = ProjectInstance.new()
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::ProjectSpecification))
          projectInstance.AddDefinesFrom(input)
        elsif(input.is_a?(RakeBuilder::SourceUnitInstance))
          projectInstance.SourceUnits.push(input)
        elsif(input.is_a?(RakeBuilder::Library))
          projectInstance.Libraries.push(input)
        end
      end
      
      @outputs = [projectInstance]
    end
  end
end
