module Rokuby
  # This class is responsible for building a project with the gpp compiler.
  # This class and its subprocessors work as follows:
  # - Each processor is responsible for executing tasks concerned with certain parts of the project.
  # - When input is added the 
  class GppProjectBuilder < ProcessChain
    include GppProjectProcessorUtility
    include Rake::DSL
    
    attr_reader :ProjectFinder
    attr_reader :ProjectPreprocessor
    attr_reader :ProjectCompiler
    attr_reader :ProjectLibraryGatherer
    attr_reader :ProjectCreator
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)

      @ConfigurationTasks = []

      @ProjectFinder = defineProc ProjectFinder, "#{@Name}_ProjFinder", :TargetPlatforms => [PLATFORM_UBUNTU]
      @ProjectPreprocessor = defineProc GppProjectPreprocessor, "#{@Name}_ProjPrep"
      @ProjectCompiler = defineProc GppProjectCompiler, "#{@Name}_ProjComp"
      @ProjectLibraryGatherer = defineProc GppProjectLibraryGatherer, "#{@Name}_ProjLibs"
      @ProjectCreator = defineProc GppProjectCreator, "#{@Name}_ProjCreator"      
      
      _ConnectProcessors()
      
      confArg = "gppConf"
      set_arg_names([confArg])
      
      @ProjectPreprocessor.set_arg_names([confArg])
      @ProjectCompiler.set_arg_names([confArg])
      @ProjectLibraryGatherer.set_arg_names([confArg])
      @ProjectCreator.set_arg_names([confArg])
      
      @InputProcessor.set_arg_names([confArg])
      @OutputProcessor.set_arg_names([confArg])
      
      AddTaskArgumentDescriptions({confArg => ["The configuration of the project that should be build", "Corresponds to the binary extension of the PlatformConfiguration."]})
    end
    
    def _ConnectProcessors
      Connect(:in, @ProjectPreprocessor.to_s, @ProjectLibraryGatherer.to_s, :out)
      Connect(:in, @ProjectFinder.to_s, @ProjectPreprocessor.to_s, @ProjectCompiler.to_s, @ProjectCreator.to_s, :out)
            
      task @ProjectCompiler.to_s, :gppConf
      task @ProjectLibraryGatherer.to_s, :gppConf
    end
  end
end
