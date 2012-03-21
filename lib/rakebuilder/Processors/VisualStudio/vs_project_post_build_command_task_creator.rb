module RakeBuilder
  # This class is responsible for creating a task that will be used to copy needed
  # libraries into the binary folder.
  class VsPostBuildCommandTaskCreator < Processor
    include VsProjectProcessorUtility
    
    attr_accessor :PostBuildTask
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @PostBuildTask = nil
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs()
      _SortInputs()
      
      if(@projectInstance == nil)
        raise "No ProjectInstance in #{self.class}:#{@Name}"
      end
      
      if(@PostBuildTask != nil)
        @vsProjectConfigurations.each do |vsConf|
          
          postBuildTaskArgument = vsConf.Platform.BinaryExtension()
          
          vsConf.PostBuildCommand = "#{RAKE_BUILDER_EXECUTABLE} -f #{@ProjectFile.Path.AbsolutePath()} #{@PostBuildTask.to_s}[#{postBuildTaskArgument}]"          
          
          if(@PostBuildTask.BackTask.Arguments.length > 0 && @PostBuildTask.BackTask.Arguments[0] == postBuildTaskArgument)
            ExtendPostBuildTask(vsConf)
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
    end
    
    def ExtendPostBuildTask(vsConf)
      # currently a limitation of this is that only tasks in the same project file can be created
      puts "Extending post build command task for configuration #{vsConf.Platform.BinaryExtension()}"
      taskName = @PostBuildTask.BackTask.to_s
      
      outputDirectory = vsConf.OutputDirectory
      
      @projectInstance.Libraries.each() do |lib|
        lib.GetInstances(vsConf.Platform).each() do |libInstance|
          libInstance.FileSet.LinkFileSet.FilePaths.each() do |libFilePath|
            if(libFilePath.FileExt != "dll") # copy only dlls
              next
            end
            
            targetLibPath = outputDirectory + ProjectPath.new(libFilePath.FileName)
            
            ProjectFile().define_task Rake::FileTask, targetLibPath.AbsolutePath() => [libFilePath.AbsolutePath()] do
              cp(libFilePath.AbsolutePath(), targetLibPath.AbsolutePath())
            end
            
            ProjectFile().define_task Rake::Task, taskName => [targetLibPath.AbsolutePath()]
          end
        end
      end
    end
  end
end
