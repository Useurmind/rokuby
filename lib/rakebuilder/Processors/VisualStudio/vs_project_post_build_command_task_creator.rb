module RakeBuilder
  # This class is responsible for creating a task that will be used to copy needed
  # libraries into the binary folder.
  class VsPostBuildCommandTaskCreator < Processor
    include VsProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs()
      _SortInputs()
      
      @vsProjectConfigurations.each do |vsConf|
        #DefineCopyTask(vsConf)
      end
      
      @outputs = []
      @outputs.push(@projectInstance)
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@vsProjectDescription)
      @outputs.concat(@vsProjectConfigurations)
      @outputs.concat(@vsProjects)
    end
    
    def DefineCopyTask(vsConf)
      taskName = @Name + "_CopyLibraries_" + vsConf.Platform.BinaryExtension()
      
      task taskName
      
      outputDirectory = vsConf.OutputDirectory
      
      @projectInstance.Libraries.each() do |lib|
        lib.GetInstances(vsConf.Platform).each() do |libInstance|
          libInstance.FileSet.LinkFileSet.FilePaths.each() do |libFilePath|
            if(libFilePath.FileExt != "dll") # copy only dlls
              next
            end
            
            targetLibPath = outputDirectory + libFilePath.FileName
            task taskName => [targetLibPath.AbsolutePath()] do
              cp(libFilePath.AbsolutePath(), targetLibPath.AbsolutePath())
            end
          end
        end
      end

      vsConf.PostBuildCommand = "#{RAKE_BUILDER_EXECUTABLE} #{taskName}"
    end
  end
end
