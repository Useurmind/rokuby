module RakeBuilder
  # This class derives automatic values for the solution description if they were
  # not set by the user.
  class VsSolutionPreprocessor < Processor
    include VsSolutionProcessorUtility
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
    
      if(@vsSolutionDescription.Name == "" || @vsSolutionDescription.Name == nil)
        @vsSolutionDescription.Name = "NoName"
      end
      
      if(@vsSolutionDescription.SolutionFilePath == nil)
        @vsSolutionDescription.SolutionFilePath = ProjectPath.new("solutions") + ProjectPath.new(@vsSolutionDescription.Name + ".sln") 
      end
      
      @outputs.push(@vsSolutionDescription)
    end
  end
end
