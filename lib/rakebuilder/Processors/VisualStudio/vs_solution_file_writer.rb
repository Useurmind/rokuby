module RakeBuilder
  # This class is a processor meant to write out the file that represent a
  # visual studio solution.
  # It takes the necessary vs solution descriptions and projects
  # to create the file. There is no output from this processor and it only reads
  # the values that are given in the objects to create the files (there are no changes
  # made to them).
  class VsSolutionFileWriter < Processor
    include VsSolutionProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      
      _CreateSolutionFile()
    end
    
    def _CreateSolutionFile
      solutionFileCreator = SolutionFileCreator.new()
      solutionFileCreator.VsSolutionDescription = @vsSolutionDescription
      solutionFileCreator.VsProjects = @vsProjects
      solutionFileCreator.BuildFile()
    end
  end
end