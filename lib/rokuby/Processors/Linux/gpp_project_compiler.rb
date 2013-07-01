module Rokuby
  # Responsible for compiling the sources that belong to the project.
  # This is the class that actually executes the GPP compiler to compile
  # and link the sources, headers and libraries.
  class GppProjectCompiler < Processor
    include GppProjectProcessorUtility
    include ProcessorUtility
    include DirectoryUtility

    def initialize(name, app, project_file)
      super(name, app, project_file)

      @includePaths = {}
      @defines = {}

      _RegisterInputTypes()
    end

    # return a path that is compatible with the command line of linux
    # @param [String] path The path to transform.
    # @return [String] The path in a form that is compatile to the command line.
    def _GetCommandLinePath(path)
      rpath = path.gsub(/\s/, "\\\s")
      #puts "Compatible path '#{rpath}'"
      return rpath
    end

    def _ProcessInputs(taskArgs=nil)
      platBinExt = GetPlatformBinaryExtensions(taskArgs)
      
      _SortInputs()
      
      gppConf = _GetGppProjectConf(platBinExt)
      #puts "Compiling #{[gppConf]}"
      
      compileTasks = _CreateCompileTasks(gppConf)
      compileTaskNames = []
      compileTasks.each() do |task|
        compileTaskNames.push task.to_s
      end
      
      linkTask = _CreateLinkTasks(gppConf, compileTaskNames)
      
      @BackTask.enhance [linkTask.to_s]

      _CreateDirectories(gppConf)
      _ExecuteBackTask()      
      
      _ForwardOutputs()
    end

    def _CreateDirectories(gppConf)
      CreatePath(gppConf.CompileDirectory)
      CreatePath(gppConf.OutputDirectory)
    end

    def _CreateCompileTasks(gppConf)
      compileTasks = []
      @projectInstance.SourceUnits.each() do |su|
        su.SourceFileSet.FilePaths.each() do |sourcePath|
          compileTasks.push _CreateCompileTask(gppConf, sourcePath)          
        end
      end
      return compileTasks
    end

    def _CreateCompileTask(gppConf, sourcePath)
      targetPath = _GetTargetPath(gppConf, sourcePath)
      compileCommand = _GetCompileCommand(gppConf, sourcePath, targetPath)
            
      #puts "Created compile command for #{sourcePath}: #{compileCommand}"
            
      return CreateFileTask({
        filePath: _GetCommandLinePath(targetPath.RelativePath),
        dependencies: [_GetCommandLinePath(sourcePath.RelativePath)],
        command: compileCommand,
        error: "Could not compile #{sourcePath.to_s} to #{targetPath.to_s}."
      })
    end
    
    def _CreateLinkTasks(gppConf, compileTaskNames)
      binaryPath = gppConf.OutputDirectory + ProjectPath.new(gppConf.TargetName + gppConf.TargetExt)
      
      commandParts = []

      binaryCommandLinePath = _GetCommandLinePath(binaryPath.RelativePath)
      
      if(@projectDescription.BinaryType == :Application)
        commandParts.concat(["g++", "-o", binaryCommandLinePath])
        commandParts.concat(gppConf.LinkOptions)
        commandParts.concat(_MapCompileDefines(gppConf))
        commandParts.concat(compileTaskNames)
        commandParts.concat(_GatherLibraryLinkComponents(gppConf))
        
      elsif(@projectDescription.BinaryType == :Shared)
        commandParts.concat(["g++", "-shared", "-fPIC", "-o", binaryCommandLinePath])
        commandParts.concat(gppConf.LinkOptions)
        commandParts.concat(_MapCompileDefines(gppConf))
        commandParts.concat(compileTaskNames)
        commandParts.concat(_GatherLibraryLinkComponents(gppConf))
        
      elsif(@projectDescription.BinaryType == :Static)
        commandParts.concat(["ar", "cq", binaryCommandLinePath])
        commandParts.concat(compileTaskNames)
      else
        raise "Unknown BinaryType '#{@projectDescription.BinaryType}' encountered in #{self.class}"
      end
      command = commandParts.join(" ")

      return CreateFileTask({
        filePath: binaryCommandLinePath,
        dependencies: compileTaskNames,
        command: command,
        error: "Failed to link #{binaryPath}"
      })
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
      compileCommandParts.push(_MapCompileIncludePaths(gppConf))
      compileCommandParts.push(_MapCompileDefines(gppConf))

      compileCommandParts.push("-o")
      compileCommandParts.push(_GetCommandLinePath(targetPath.RelativePath))
      compileCommandParts.push(_GetCommandLinePath(sourcePath.RelativePath))
      
      return compileCommandParts.join(" ")
    end

    def _MapCompileIncludePaths(gppConf)
      includePaths = @includePaths[gppConf.Platform.Name]
      if(includePaths)
        return includePaths
      end
      
      @includePaths[gppConf.Platform.Name] = (gppConf.IncludePaths.map() {|include| Gpp::CommandLine::Options::INCLUDE_DIRECTORY + _GetCommandLinePath(include.RelativePath())}).uniq
      return @includePaths[gppConf.Platform.Name]
    end

    def _MapCompileDefines(gppConf)
      defines = @defines[gppConf.Platform.Name]
      if(defines)
        return defines
      end

      @defines[gppConf.Platform.Name] = (gppConf.Defines.map() {|define| Gpp::CommandLine::Options::DEFINE + define}).uniq
      return @defines[gppConf.Platform.Name]
    end
    
    def _GatherLibraryLinkComponents(gppConf)
      workingDir = ProjectPath.new(".")
      dynamicLibsSearchPaths = Set.new
      dynamicLibs = []
      staticLibs = []

      gppConf.AdditionalPreLibraries.each() do |preLib|
        dynamicLibs.push(Gpp::CommandLine::Options::LIB_NAME + preLib)
      end

      dynamicLibExtension = Gpp::Configuration::TargetExt::SHARED_LIB.gsub("\.", "")

      # the libraries that are included in this project
      @projectInstance.Libraries.each() do |lib|
        libInstance = lib.GetInstance(gppConf.Platform)
        if(!libInstance)
          next
        end

        libPath = libInstance.FileSet.LibraryFileSet.FilePaths[0]
        if(!libPath)
          puts "WARNING No library file path found for library #{lib.Name}"
          next
        end
        libPath = libPath.MakeRelativeTo(workingDir)
        
        libExtension = libPath.FileExt()
        if(libExtension == dynamicLibExtension)
          dynamicLibs.push  Gpp::CommandLine::Options::LIB_NAME + _GetLibLinkName(libPath.FileName(false))
          dynamicLibsSearchPaths.add Gpp::CommandLine::Options::LIB_DIRECTORY + _GetCommandLinePath(libPath.DirectoryPath().RelativePath)
        else
          staticLibs.push _GetCommandLinePath(libPath.RelativePath)
        end
      end
      
      # the libraries that are created by other projects
      @gppProjects.each() do |gppProject|
        projGppConf = gppProject.GetConfiguration(gppConf.Platform)
        projectLibFilePath = projGppConf.GetTargetFilePath().MakeRelativeTo(workingDir)
        if(projGppConf.TargetExt == Gpp::Configuration::TargetExt::SHARED_LIB)
          dynamicLibs.push Gpp::CommandLine::Options::LIB_NAME + _GetLibLinkName(projectLibFilePath.FileName(false))
          dynamicLibsSearchPaths.add Gpp::CommandLine::Options::LIB_DIRECTORY + _GetCommandLinePath(projectLibFilePath.DirectoryPath().RelativePath)
        elsif(projGppConf.TargetExt == Gpp::Configuration::TargetExt::STATIC_LIB)
          staticLibs.push _GetCommandLinePath(projectLibFilePath.RelativePath)
        end
      end
      
      gppConf.AdditionalPostLibraries.each() do |postLib|
        dynamicLibs.push(Gpp::CommandLine::Options::LIB_NAME + postLib)
      end
      
      return dynamicLibsSearchPaths.to_a() + dynamicLibs + staticLibs
    end
    
    def _GetLibLinkName(fullName)
      return fullName.gsub(/^lib/, "")
    end
  end
end
