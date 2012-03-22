module RakeBuilder
  # Responsible for compiling the sources that belong to the project.
  class GppProjectCompiler < GppProjectProcessorUtility
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end

    def _ProcessInputs
      _SortInputs()

      _CreateCompileTasks()

      _ExecuteBackTask()
      
      _ForwardOutputs()
    end

    def _CreateCompileTasks(gppConf)
      @projectInstance.SourceUnits.each() do |su|
        su.SourceFileSet.FilePaths.each() do |sourcePath|
          _CreateCompileTask(gppConf, sourcePath)          
        end
      end
    end

    def _CreateCompileTask(gppConf, sourcePath)
      targetPath = _GetTargetPath(gppConf, sourcePath)
      compileCommand = _GetCompileCommand(gppConf, sourcePath, targetPath)
            
      CreateFileTask {
        filePath: targetPath.AbsolutePath(),
        dependencies: [sourcePath.AbsolutePath()],
        command: compileCommand,
        error: "Could not compile #{sourceFilePath.to_s} to #{targetFilePath.to_s}."
      }

      CreateTask @BackTask => [targetPath.AbsolutePath()]
    end

    def _GetTargetPath(gppConf, sourcePath)
      return gppConf.CompileDirectory + ProjectPath.new(sourcePath.FileName(false) + ".o")
    end

    def _GetCompileCommand(gppConf, sourcePath, targetPath)

      compileCommandParts = ["g++ -c"]
      if(@projectDescription.BinaryType == :Shared || @projectDescription.BinaryType == :Static)
        compileCommandParts.push "-fPIC"
      end
      compileCommandParts.concat(gppConf.CompileOptions)      
      compileCommandParts.push(_GatherIncludePaths(gppConf))
      compileCommandParts.push(_GatherDefines(gppConf))

      compileCommandParts.push("-o")
      compileCommandParts.push(targetPath.RelativePath())
      compileCommandParts.push(sourcePath.RelativePath())
      
      return compileCommandParts.join(" ")
    end

    def _GatherIncludePaths
    end

    def _GatherDefines(gppConf)
      defines = []
      defines |= @projectInstance.GatherDefines(gppConf.Platform)
      defines |= @projectDescription.GatherDefines()
      defines |= @gppProjectDescription.GatherDefines()
      #puts "found defines for vsconf: #{defines}"
      @gppProjects.each() do|gppProj|
        defines |= gppProj.GetPassedDefines(gppConf.Platform)
      end
      return defines
    end
  end
end