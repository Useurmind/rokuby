module Rokuby
  # This class creates project and filter file for a given project and produces a
  # VSProject instance that can be used in other projects.
  # This builder works like a normal builder but additionally accepts a visual studio
  # project description, one visual studio instance and several configurations.
  # The configurations are associated with the project configurations by means of the
  # platform they are defined for. Make sure that there is at most one visual studio and normal
  # project configuration for each platform.
  # Output of this processor is a VSProject instance that represents the created project.
  class VsProjectBuilder < ProcessChain
    include Rake::DSL
    
    attr_reader :ProjectFinder
    attr_reader :ProjectPreprocessor
    attr_reader :ProjectCreator
    attr_reader :FileWriter
    attr_reader :VsProjectFinder
    attr_reader :VsPostBuildTaskCreator
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @ProjectFinder = defineProc ProjectFinder, _GetProcessorName("ProjFinder"), :TargetPlatforms => [PLATFORM_WIN]
      @ProjectPreprocessor = defineProc VsProjectPreprocessor, _GetProcessorName("Pre")
      @ProjectCreator = defineProc VsProjectCreator, _GetProcessorName("Proj")
      @FileWriter = defineProc VsProjectFilesWriter, _GetProcessorName("Files")
      @VsProjectFinder = defineProc VsProjectFinder, _GetProcessorName("VsProjFinder")
      @VsPostBuildTaskCreator = defineProc VsPostBuildCommandTaskCreator, _GetProcessorName("PostBuild")
      
      _ConnectProcessors()
    end
    
    def intialize_copy(original)
      super(original)
      @ProjectFinder = original.ProjectFinder
      @ProjectPreprocessor = original.ProjectPreprocessor
      @ProjectCreator = original.ProjectCreator
      @FileWriter = original.FileWriter
      @VsProjectFinder = original.VsProjectFinder
      @VsPostBuildTaskCreator = original.VsPostBuildTaskCreator
    end
    
    def AdaptName(newName)
      oldName = name()
      
      super(newName)
      
      projecFinderName = _AdaptProcessorName(newName, oldName, @ProjectFinder.to_s)
      projectPreprocessorName = _AdaptProcessorName(newName, oldName, @ProjectPreprocessor.to_s)
      libFinderName = _AdaptProcessorName(newName, oldName, @ProjectCreator.to_s)
      fileWriterName = _AdaptProcessorName(newName, oldName, @FileWriter.to_s)
      vsProjectFinderName = _AdaptProcessorName(newName, oldName, @VsProjectFinder.to_s)
      vsPostBuildTaskCreatorName = _AdaptProcessorName(newName, oldName, @VsPostBuildTaskCreator.to_s)
      
      @ProjectFinder = @ChainProcessors[projecFinderName]
      @ProjectPreprocessor = @ChainProcessors[projectPreprocessorName]
      @ProjectCreator = @ChainProcessors[libFinderName]
      @FileWriter = @ChainProcessors[fileWriterName]
      @VsProjectFinder = @ChainProcessors[vsProjectFinderName]
      @VsPostBuildTaskCreator = @ChainProcessors[vsPostBuildTaskCreatorName]
      
      _ConnectProcessors()
    end
    
    def _ConnectProcessors
      Connect(:in, @ProjectFinder.to_s, @ProjectPreprocessor.to_s)
      Connect(:in, @VsProjectFinder.to_s, @ProjectPreprocessor.to_s)
      Connect(:in, @ProjectPreprocessor.to_s, @VsPostBuildTaskCreator.to_s)      
      Connect(@ProjectCreator.to_s, :out)
      Connect(@FileWriter.to_s, @ProjectCreator.to_s)
      Connect(@VsPostBuildTaskCreator.to_s, @ProjectCreator.to_s)
      Connect(@VsPostBuildTaskCreator.to_s, @FileWriter.to_s)
      
      # The first argument to this task is the configuration name for which the post build should be executed
      @PostBuildTask = Rake::ProxyTask.define_task _GetProcessorName("PostBuildCommandTask"), :descr, :inst, :vsDescr, :vsInst, :vsConf
      @PostBuildLibCopyTask = Rake::Task.define_task _GetProcessorName("PostBuildLibCopyTask"), :descr, :inst, :vsDescr, :vsInst, :vsConf
      
      @PostBuildTask.SetArgumentModificationAction() do |args|
        
        vsConfBinaryExt = args[0]
        
        $EXECUTION_MODE = :Restricted
        @VsPostBuildTaskCreator.CurrentVsConfBinaryExt = vsConfBinaryExt
        @VsPostBuildTaskCreator.invoke()
        
        modifiedArgs = []
        
        modifiedArgs.push @VsPostBuildTaskCreator.GetOutputByClass(ProjectDescription)
        modifiedArgs.push @VsPostBuildTaskCreator.GetOutputByClass(ProjectInstance)
        
        modifiedArgs.push @VsPostBuildTaskCreator.GetOutputByClass(VsProjectDescription)
        modifiedArgs.push @VsPostBuildTaskCreator.GetOutputByClass(VsProjectInstance)
        
        @VsPostBuildTaskCreator.GetOutputsByClass(VsProjectConfiguration).each() do |vsConf|
          if(vsConf.Platform.BinaryExtension == vsConfBinaryExt)
            modifiedArgs.push vsConf
            break
          end
        end
        
        modifiedArgs
      end
      @PostBuildTask.enhance [@PostBuildLibCopyTask.to_s]  # as the pres are executed corresponding to their order this executes the back task last
      
      @VsPostBuildTaskCreator.PostBuildTask = @PostBuildTask
      @VsPostBuildTaskCreator.PostBuildLibCopyTask = @PostBuildLibCopyTask
    end
    
    def _InitProc
    end
    
    # Overwrite this in derived processors to print a message before the processor is executed
    def _LogTextBeforeExecute
      "Building project #{@Name}..."
    end
    
    # Overwrite this in derived processors to print a message after the processor was executed
    def _LogTextAfterExecute
      "Project #{@Name} was build."
    end
    
    def _OnAddInput(input)
      if(!super(input))
        return false
      end
      if(input.is_a?(ProjectDescription))
        clean input.CompilesPath.RelativePath
        clean input.BuildPath.RelativePath
      elsif(input.is_a?(VsProjectDescription))
        clean input.ProjectBasePath.RelativePath
      end
      return true
    end
    
    # Extend/set the attributes of the processor.
    def Extend(valueMap, executeParent=true)
      if(valueMap == nil)
        return
      end
      
      if(executeParent)
        super(valueMap)
      end
      
      postBuildTasks = valueMap[:PostBuildTasks] || valueMap[:postBuild]
      if(postBuildTasks)
        @PostBuildTask.enhance postBuildTasks
      end
    end
  end
end
