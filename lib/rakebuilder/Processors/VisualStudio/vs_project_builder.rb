module RakeBuilder
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
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @projectFinder = defineProc ProjectFinder, "#{@Name}_ProjFinder", :TargetPlatforms => [PLATFORM_WIN]
      @projectPreprocessor = defineProc VsProjectPreprocessor, "#{@Name}_Pre"
      @projectCreator = defineProc VsProjectCreator, "#{@Name}_Proj"
      @fileWriter = defineProc VsProjectFilesWriter, "#{@Name}_Files"
      @vsProjectFinder = defineProc VsProjectFinder, "#{@Name}_VsProjFinder"
      @vsPostBuildTaskCreator = defineProc VsPostBuildCommandTaskCreator, "#{@Name}_PostBuild"
      
      Connect(:in, @projectFinder.to_s, @projectPreprocessor.to_s)
      Connect(:in, @vsProjectFinder.to_s, @fileWriter.to_s)
      Connect(:in, @projectPreprocessor.to_s, @vsPostBuildTaskCreator.to_s)      
      Connect(@projectCreator.to_s, :out)
      Connect(@fileWriter.to_s, @projectCreator.to_s)
      Connect(@vsPostBuildTaskCreator.to_s, @projectCreator.to_s)
      Connect(@vsPostBuildTaskCreator.to_s, @fileWriter.to_s)
      
      # The first argument to this task is the configuration name for which the post build should be executed
      @PostBuildTask = Rake::ProxyTask.define_task "#{@Name}_PostBuildCommandTask", :descr, :inst, :vsDescr, :vsInst, :vsConf
      @PostBuildLibCopyTask = Rake::Task.define_task "#{@Name}_PostBuildLibCopyTask", :descr, :inst, :vsDescr, :vsInst, :vsConf
      
      @PostBuildTask.SetArgumentModificationAction() do |args|
        
        vsConfBinaryExt = args[0]
        
        $EXECUTION_MODE = :Restricted
        @vsPostBuildTaskCreator.CurrentVsConfBinaryExt = vsConfBinaryExt
        @vsPostBuildTaskCreator.invoke()
        
        modifiedArgs = []
        
        modifiedArgs.push @vsPostBuildTaskCreator.ProjectDescription
        modifiedArgs.push @vsPostBuildTaskCreator.ProjectInstance
        
        modifiedArgs.push @vsPostBuildTaskCreator.VsProjectDescription
        modifiedArgs.push @vsPostBuildTaskCreator.VsProjectInstance
        
        @vsPostBuildTaskCreator.VsProjectConfigurations.each() do |vsConf|
          if(vsConf.Platform.BinaryExtension == vsConfBinaryExt)
            modifiedArgs.push vsConf
            break
          end
        end
        
        modifiedArgs
      end
      @PostBuildTask.enhance [@PostBuildLibCopyTask.to_s]  # as the pres are executed corresponding to their order this executes the back task last
      
      @vsPostBuildTaskCreator.PostBuildTask = @PostBuildTask
      @vsPostBuildTaskCreator.PostBuildLibCopyTask = @PostBuildLibCopyTask
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
