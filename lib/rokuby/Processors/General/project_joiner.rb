module Rokuby
  # This class is part of a project finder process chain.
  # It is used to fuse the libraries and source units into a final project instance.
  class ProjectJoiner < Processor
    
    def _InitProc
      @knownInputClasses.push(Rokuby::ProjectSpecification)
      @knownInputClasses.push(Rokuby::ProjectInstance)
      @knownInputClasses.push(Rokuby::SourceUnitInstance)
      @knownInputClasses.push(Rokuby::Library)
    end
    
    def _ProcessInputs(taskArgs=nil)      
      projectInstance = ProjectInstance.new()
      @inputs.each() do |input|
        if(input.is_a?(Rokuby::ProjectSpecification))
          projectInstance.AddDefinesFrom(input)
        elsif(input.is_a?(Rokuby::SourceUnitInstance))
          projectInstance.SourceUnits.push(input)
        elsif(input.is_a?(Rokuby::Library))
          projectInstance.Libraries.push(input)
        end
      end
      
      @outputs = [projectInstance]
    end
  end
end
