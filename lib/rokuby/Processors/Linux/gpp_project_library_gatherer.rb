module Rokuby
  class GppProjectLibraryGatherer < Processor
    include GppProjectProcessorUtility
    include ProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end
    
    def _ProcessInputs(taskArgs=nil)
      _SortInputs()
      
      gppConf = _GetGppProjectConf(taskArgs.gppConf.Platform)

      if(gppConf)
        libraryPaths = _GatherLibraryPaths(gppConf)

        libraryPaths.each() do |libPath|
          _CreateLibCopyTask(libPath, gppConf)
        end

        _ExecuteBackTask()
      end
    end
    
    def _GatherLibraryPaths(gppConf)
      return []
    end
    
    def _CreateLibCopyTask(libPath, gppConf)
      targetPath = gppConf.OutputDirectory + ProjectPath.new(libPath.FileName())
      
      targetPath = targetPath.MakeRelativeTo(@ProjectFile.Path)
      sourcePath = libPath.MakeRelativeTo(@ProjectFile.Path)
      
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
