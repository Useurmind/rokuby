module RakeBuilder
  # This class is responsible for creating a task that will be used to copy needed
  # libraries into the binary folder.
  class VsPostBuildCommandTaskCreator < Processor
    include VsProjectProcessorUtility
    
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
    
    def _ProcessInputs()
      _SortInputs()
      
      if(@projectInstance == nil)
        raise "No ProjectInstance in #{self.class}:#{@Name}"
      end
      
      #puts "postBuildTask: #{@PostBuildTask}"
      #puts "PostBuildLibCopyTask: #{@PostBuildLibCopyTask}"
      #puts "CurrentVsConfBinaryExt: #{@CurrentVsConfBinaryExt}"
      
      if(@PostBuildTask != nil && @PostBuildLibCopyTask != nil)
      
        @vsProjectConfigurations.each do |vsConf|
          vsConfBinaryExt = vsConf.Platform.BinaryExtension()
          vsConf.PostBuildCommand = "#{RAKE_BUILDER_EXECUTABLE} -f #{@ProjectFile.Path.AbsolutePath()} #{@PostBuildTask.to_s}[#{vsConfBinaryExt}]"          
        
          if(@CurrentVsConfBinaryExt != nil && @CurrentVsConfBinaryExt == vsConfBinaryExt) # this is the configuration for which the postbuild task was executed
            _ExtendPostBuildLibCopyTask(vsConf)
          end
        end
      
      end
      
      @outputs = []
      @outputs.push(@projectInstance)
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@vsProjectDescription)
      @outputs.concat(@vsProjectConfigurations)
      @outputs.concat(@vsProjects)
      @outputs.concat(@passthroughDefines)
    end
    
    def _ExtendPostBuildLibCopyTask(vsConf)
      # currently a limitation of this is that only tasks in the same project file can be created
      #puts "Extending post build command task for configuration #{vsConf.Platform.BinaryExtension()}"
      
      outputDirectory = vsConf.OutputDirectory
      
      librariesToCopy = @projectInstance.Libraries
      
      
      # task for copying the project outputs of projects on which this project depends
      @vsProjects.each() do |vsProj|
        vsProjConf = vsProj.GetConfiguration(vsConf.Platform)
        
        projOutputPath = vsProjConf.GetTargetFilePath()
        
        _CreateCopyTask(projOutputPath, outputDirectory)
        
        librariesToCopy |= vsProj.Libraries
      end
      
      # task for copying the library on which this project depends
      librariesToCopy.each() do |lib|
        lib.GetInstances(vsConf.Platform).each() do |libInstance|
          libInstance.FileSet.LinkFileSet.FilePaths.each() do |libFilePath|
            if(libFilePath.FileExt != "dll") # copy only dlls
              next
            end
            
            _CreateCopyTask(libFilePath, outputDirectory)
          end
        end
      end
    end
    
    def _CreateCopyTask(sourceFilePath, outputDirectoryPath)#
      taskName = @PostBuildLibCopyTask.to_s
      targetFilePath = outputDirectoryPath + ProjectPath.new(sourceFilePath.FileName)
      
      ProjectFile().define_task Rake::FileTask, targetFilePath.AbsolutePath() => [sourceFilePath.AbsolutePath()] do
        FileUtils.cp(sourceFilePath.AbsolutePath(), targetFilePath.AbsolutePath())
      end
      
      ProjectFile().define_task Rake::Task, taskName => [targetFilePath.AbsolutePath()]
    end
  end
end
