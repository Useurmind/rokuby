module RakeBuilder
  # This class is responsible for building a project with the gpp compiler.
  # This class and its subprocessors work as follows:
  # - Each processor is responsible for executing tasks concerned with certain parts of the project.
  # - When input is added the 
  class GppProjectBuilder < ProcessChain
    include GppProjectProcessorUtility
    include Rake::DSL
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)

      @ConfigurationTasks = []

      @projectFinder = defineProc ProjectFinder, "#{@Name}_ProjFinder"
      @projectPreprocessor = defineProc GppProjectPreprocessor, "#{@Name}_ProjPrep"
      @projectCompiler = defineProc GppProjectCompiler, "#{@Name}_ProjComp"
      @projectLibraryGatherer = defineProc GppProjectLibraryGatherer, "#{@Name}_ProjLibs"
      @projectCreator = defineProc GppProjectCreator, "#{@Name}_ProjCreator"

      task @projectCompiler.to_s, :gppConf
      task @projectLibraryGatherer.to_s, :gppConf

      Connect(:in, @projectFinder.to_s, @projectPreprocessor.to_s, @projectCompiler.to_s, @projectLinker.to_s, @projectCreator.to_s, :out)
      Connect(:@projectPreprocessor.to_s, @projectLibraryGatherer, :out)
    end
    
    def AddInput(inputs)
      if(inputs.length != nil)
        inputs.each() do |input|
          _AddConfigurationTask(input)
        end
      else
        _AddConfigurationTask(input)
      end
      super(inputs)
    end
    
    def _AddConfigurationTask(input)
      if(input.is_a?(GppProjectConfiguration))
        desc "Build the project of #{@Name} with configuration #{input.Platform.BinaryExtension()}"
        confTask = Rake::ProxyTask.define_task "#{@Name}_#{input.Platform.BinaryExtension()}", :gppConf => [@projectCompiler.to_s]
        
        confTask.SetArgumentModificationAction() do |args|
          input
        end
        
        @ConfigurationTasks.push confTask
      end
    end
  end
end