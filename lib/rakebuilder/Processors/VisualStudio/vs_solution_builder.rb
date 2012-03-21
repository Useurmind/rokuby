module RakeBuilder
  # This processor is responsible for building a visual studio solution out of different
  # visual studio projects.
  # The processor needs one VSSolutionDescription and one to several VSProject(s).
  # The processor does not produce any output.
  class VsSolutionBuilder < ProcessChain
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @solutionPreprocessor = defineProc VsSolutionPreprocessor, "#{@Name}_Pre"
      @fileWriter = defineProc VsSolutionFileWriter, "#{@Name}_File"
      
      Connect(:in, @solutionPreprocessor.to_s, :out)
      Connect(:in, @solutionPreprocessor.to_s, @fileWriter.to_s, :out)
    end
  end
end
