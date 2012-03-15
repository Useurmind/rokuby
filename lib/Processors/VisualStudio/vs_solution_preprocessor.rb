module RakeBuilder
  # This class derives automatic values for the solution description if they were
  # not set by the user.
  class VsSolutionPreprocessor < Processor
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
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
