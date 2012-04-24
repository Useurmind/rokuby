module RakeBuilder
  # This processor is responsible for building a visual studio solution out of different
  # visual studio projects.
  # The processor needs one VSSolutionDescription and one to several VSProject(s).
  # The processor does not produce any output.
  class VsSolutionBuilder < ProcessChain
    include Rake::DSL
    
    attr_reader :SolutionPreprocessor
    attr_reader :FileWriter
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @SolutionPreprocessor = defineProc VsSolutionPreprocessor, _GetProcessorName("Pre")
      @FileWriter = defineProc VsSolutionFileWriter, _GetProcessorName("File")
      
      _ConnectProcessors()
    end
    
    def intialize_copy(original)
      super(original)
      @SolutionPreprocessor = original.SolutionPreprocessor
      @FileWriter = original.FileWriter
    end
    
    def AdaptName(newName)
      oldName = name()
      
      super(newName)
      
      solutionPreprocessorName = _AdaptProcessorName(newName, oldName, @SolutionPreprocessor.to_s)
      fileWriterName = _AdaptProcessorName(newName, oldName, @FileWriter.to_s)
      
      @SolutionPreprocessor = @ChainProcessors[solutionPreprocessorName]
      @FileWriter = @ChainProcessors[fileWriterName]
      
      _ConnectProcessors()
    end
    
    def _ConnectProcessors
      #puts "Connecting processors in solution builder"
      Connect(:in, @SolutionPreprocessor.to_s, @FileWriter.to_s, :out)
    end
    
    def _OnAddInput(input)
      if(!super(input))
        return false
      end
      if(input.is_a?(VsSolutionDescription))
        #puts "adding solution description to clean target"
        clean input.SolutionBasePath.RelativePath
      end
      return false
    end
  end
end
