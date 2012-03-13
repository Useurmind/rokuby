module RakeBuilder
  # This class derives automatic values for the solution description if they were
  # not set by the user.
  class VSSolutionPreprocessor < Processor
    def initialize(name)
      super(name)
      
      @knownInputClasses.push(RakeBuilder::SolutionDescription)
    end
    
    def _ProcessInputs
      @inputs.each() do |solDescr|
        if(solDescr.Name == "" || solDescr.Name == nil)
          solDescr.Name = "NoName"
        end
        
        if(solDescr.SolutionFilePath == nil)
          solDescr.SolutionFilePath = ProjectPath.new("VsSolution")
        end
        
        @outputs.push(solDescr)
      end
    end
  end
end
