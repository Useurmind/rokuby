module RakeBuilder
  # This class is responsible for creating a task that will be used to copy needed
  # libraries into the binary folder.
  class VsPostBuildCommandTaskCreator < Processor
    include VsProjectProcessorUtility
    include ProcessorUtility
    
    attr_accessor :PostBuildTask
    attr_accessor :PostBuildLibCopyTask
    attr_accessor :CurrentVsConfBinaryExt
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @PostBuildTask = nil
      @PostBuildLibCopyTask = nil
      @CurrentVsConfBinaryExt = nil
      
      _RegisterInputTypes()
    end
    
    def _CheckInputs
      if(@projectInstance == nil)
        raise "No ProjectInstance in #{self.class}:#{@Name}"
      end
    end
    
    def _ProcessInputs(taskArgs=nil)
      _SortInputs()
      
      _CheckInputs()
      
      #puts "postBuildTask: #{@PostBuildTask}"
      #puts "PostBuildLibCopyTask: #{@PostBuildLibCopyTask}"
      #puts "CurrentVsConfBinaryExt: #{@CurrentVsConfBinaryExt}"
      
      if(@PostBuildTask != nil && @PostBuildLibCopyTask != nil)
      
        @vsProjectConfigurations.each do |vsConf|
          vsConfBinaryExt = vsConf.Platform.BinaryExtension()
          vsConf.PostBuildCommand = "#{RAKE_BUILDER_EXECUTABLE} -f #{@ProjectFile.Path.AbsolutePath()} #{@PostBuildTask.to_s}[#{vsConfBinaryExt}]"          
        end
      
      end
      
      _ForwardOutputs()
    end
    
    def _ForwardOutputs
      @outputs = []
      @outputs.push(@projectInstance)
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@vsProjectDescription)
      @outputs.concat(@vsProjectConfigurations)
      @outputs.concat(@vsProjects)
      @outputs.concat(@passthroughDefines)
    end
    
    #########################################################
    # Post processing
    
    def _ExecutePostProcessing(taskArgs=nil)
      vsConfigurations = _GetOutputsByClass(VsProjectConfiguration)
      
      if(@PostBuildTask != nil && @PostBuildLibCopyTask != nil)
        vsConfigurations.each do |vsConf|
          vsConfBinaryExt = vsConf.Platform.BinaryExtension()
        
          if(@CurrentVsConfBinaryExt != nil && @CurrentVsConfBinaryExt == vsConfBinaryExt) # this is the configuration for which the postbuild task was executed
            _ExtendPostBuildLibCopyTask(vsConf)
          end
        end
      end
    end
    
    def _ExtendPostBuildLibCopyTask(vsConf)
      # currently a limitation of this is that only tasks in the same project file can be created
      #puts "Extending post build command task for configuration #{vsConf.Platform.BinaryExtension()}"
      
      projectInstance = _GetOutputByClass(ProjectInstance)
      vsProjects = _GetOutputsByClass(VsProject)
      
      outputDirectory = vsConf.OutputDirectory
      
      librariesToCopy = projectInstance.Libraries
      
      
      # task for copying the project outputs of projects on which this project depends
      vsProjects.each() do |vsProj|
        vsProjConf = vsProj.GetConfiguration(vsConf.Platform)
        
        projOutputPath = vsProjConf.GetTargetFilePath()
        
        _CreateCopyTask(projOutputPath, outputDirectory)
        
        librariesToCopy |= vsProj.Libraries
      end
      
      # task for copying the library on which this project depends
      librariesToCopy.each() do |lib|
        libInstance = lib.GetInstance(vsConf.Platform)
        if(libInstance != nil)
          libInstance.FileSet.LinkFileSet.FilePaths.each() do |libFilePath|
            if(libFilePath.FileExt != "dll") # copy only dlls
              next
            end
            
            _CreateCopyTask(libFilePath, outputDirectory)
          end
        end
      end
    end
    
    def _CreateCopyTask(sourceFilePath, outputDirectoryPath)
      taskName = @PostBuildLibCopyTask.to_s
      targetFilePath = outputDirectoryPath + ProjectPath.new(sourceFilePath.FileName)
      
      CreateFileTask({
        filePath: targetFilePath.AbsolutePath(),
        dependencies: [sourceFilePath.AbsolutePath()],
        command: "cp #{sourceFilePath.AbsolutePath()} #{targetFilePath.AbsolutePath()}",
        error: "Could not copy #{sourceFilePath.to_s} to #{targetFilePath.to_s}."
      })
      
      CreateTask taskName => [targetFilePath.AbsolutePath()]
    end
  end
end
