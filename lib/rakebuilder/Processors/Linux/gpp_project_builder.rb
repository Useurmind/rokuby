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

      @projectFinder = defineProc ProjectFinder, "#{@Name}_ProjFinder", :TargetPlatforms => [PLATFORM_UBUNTU]
      @projectPreprocessor = defineProc GppProjectPreprocessor, "#{@Name}_ProjPrep"
      @projectCompiler = defineProc GppProjectCompiler, "#{@Name}_ProjComp"
      @projectLibraryGatherer = defineProc GppProjectLibraryGatherer, "#{@Name}_ProjLibs"
      @projectCreator = defineProc GppProjectCreator, "#{@Name}_ProjCreator"      
      
      task @projectCompiler.to_s, :gppConf
      task @projectLibraryGatherer.to_s, :gppConf

      Connect(:in, @projectPreprocessor.to_s, @projectLibraryGatherer.to_s, :out)
      Connect(:in, @projectFinder.to_s, @projectPreprocessor.to_s, @projectCompiler.to_s, @projectCreator.to_s, :out)
      
    end
    
    def AddInput(inputs)
      #puts "Adding input to GppProjectbuilder #{inputs}"
      if(inputs.class == Array)
        inputs.each() do |input|
          _AddConfigurationTask(input)
        end
      else
        _AddConfigurationTask(inputs)
      end
      super(inputs)
    end
    
    def _AddConfigurationTask(input)
      #puts "Trying to create configuration task for #{input}"
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