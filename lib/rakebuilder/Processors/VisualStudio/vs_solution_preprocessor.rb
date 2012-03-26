module RakeBuilder
  # This class derives automatic values for the solution description if they were
  # not set by the user.
  class VsSolutionPreprocessor < Processor
    include VsSolutionProcessorUtility
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs(taskArgs=nil)
      _SortInputs()
    
      if(@vsSolutionDescription == nil)
        raise "No VsSolutionDescription in #{self.class}:#{@Name}"
      end
    
      if(@vsSolutionDescription.Name == "" || @vsSolutionDescription.Name == nil)
        @vsSolutionDescription.Name = "NoName"
      end
      
      if(@vsSolutionDescription.SolutionFilePath == nil)
        @vsSolutionDescription.SolutionFilePath = @vsSolutionDescription.SolutionBasePath + ProjectPath.new(@vsSolutionDescription.Name + ".sln") 
      end
      
      @outputs.push(@vsSolutionDescription)
      @outputs.concat(@vsProjects)
    end
  end
end
