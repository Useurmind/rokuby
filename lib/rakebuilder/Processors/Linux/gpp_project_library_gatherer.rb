module RakeBuilder
  class GppProjectLibraryGatherer < Processor
    include GppProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end
    
    def _ProcessInputs(taskArgs)
      _SortInputs()
      
      gppConf = taskArgs.gppConf
      
      libraryPaths = _GatherLibraryPaths(gppConf)
      
      libraryPaths.each() do |libPath|
        _CreateLibCopyTask(libPath, gppConf)
      end
      
      ExecuteBackTask()
    end
    
    def _GatherLibraryPaths()
    end
    
    def _CreateLibCopyTask(libPath, gppConf)
      targetPath = gppConf.OutputDirectory + ProjectPath.new(libPath.FileName())
      
      targetPath = targetPath.MakeRelativeTo(@projectDescription.ProjectPath)
      sourcePath = libPath.MakeRelativeTo(@projectDescription.ProjectPath)
      
      copyCommand = "cp #{libPath.AbsolutePath()} #{targetPath.AbsolutePath()}"
      
      task = CreateFileTask({
        filePath: targetPath.RelativePath,
        dependencies: [sourcePath.RelativePath],
        command: copyCommand,
        error: "Could not copy compile #{sourcePath.to_s} to #{targetPath.to_s}."
      })
      
      @BackTask.enhance [task.to_s]
    end
  end
end
