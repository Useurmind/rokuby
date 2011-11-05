require "rake"
require "rake/clean"
require "set"

module RakeBuilder

  # This class will create the necessary tasks to compile a cpp project with the gpp.
  # [CompilerOptions] The options that the compiler needs to compile the sources of this project.
  # [LinkOptions] The options that the compiler needs to link the compiled sources of this project.
  # [ProjectConfiguration] This is the configuration for the C++ project that includes all the information about the project.
  # [LibrarySearchPaths] The paths to search for libraries (default: [ "/usr/lib", "usr/local/lib" ])
  # [LibraryIncludeDirectories] The paths were the headers of the different libraries are located (default: [ "/usr/include" , "usr/locale/include" ])
  # [EndTask] This is the task that can be used to create dependencies between the creation of this project and other tasks.
  # [Dependencies] The tasks that the compilation of this object depends on.
  # [RelativeLibrarySearchPath] If this path is set a define will be set that will link the libraries in a way that at runtime they are searched
  #                             in the execution directory plus this path (set this only once).
  # After the project tasks were created with CreateProjectTasks, the EndTask can be used to build the project.
  class GppCompileOrder
    include GeneralUtility
    include DirectoryUtility

    attr_accessor :Name
    attr_accessor :CompilerOptions
    attr_accessor :LinkOptions
    attr_accessor :ProjectConfiguration    
    attr_accessor :EndTask
    attr_accessor :Dependencies
    attr_accessor :DependencyCompileOrders

    def RelativeLibrarySearchPath=(value)
      searchPath = JoinPaths(["$ORIGIN", value])
      @LinkOptions.push("-Wl,-rpath='#{searchPath}'")
    end
    
    def initialize(name)      
      @Name = name
      @CompilerOptions = []
      @LinkOptions = [] 
      @Dependencies = []
      @DependencyCompileOrders = []

      @compiles = []
    end
    
    def initialize_copy(original)
      InitCopy(original)
    end

    def InitCopy(original)
      @Name = Clone(original.Name)
      @CompilerOptions = Clone(original.CompilerOptions)
      @LinkOptions = Clone(original.LinkOptions)
      @ProjectConfiguration = Clone(original.ProjectConfiguration)

      @compiles = []
    end
  
    # Create all the necessary tasks to build the project.
    # After this operation was called the EndTask can be used to build the project.
    def CreateProjectTasks
      puts "Creating tasks for compile order with the following configuration:"
      puts @ProjectConfiguration.to_s()
      
      CreateCompilerOptionDirective()
      CreateIncludeDirectoryDirective()
      CreateDefinesDirective()

      CreateBinaryDirectoryTask()
      CreateCompileTasks()

      CreateLinkOptionDirective()
      CreateLinkCompilesDirective()
      CreateLinkLibrariesDirective()

      CreateLinkTask()
      
      CreateCleanTask()
    end
    
    # Add the files to the clean task that were produced during the build process
    def CreateCleanTask      
      CLEAN.include(@ProjectConfiguration.CompilesDirectory)
      CLEAN.include(@ProjectConfiguration.BuildDirectory)
      CLEAN.include(@ProjectConfiguration.GetFinalCompilesDirectory())
      CLEAN.include(@ProjectConfiguration.GetFinalBuildDirectory())
      CLEAN.include(@compiles)
      CLEAN.include(@ProjectConfiguration.BinaryName)
    end

    # Create the neccesary directories for the build process.
    def CreateBinaryDirectoryTask
      directory @ProjectConfiguration.GetFinalCompilesDirectory()
      directory @ProjectConfiguration.GetFinalBuildDirectory()
    end
    
    # Create one compiler command for the compilation of each source in the project.
    def CreateCompileTasks
      extendedHeaders = @ProjectConfiguration.GetExtendedIncludes()
      extendedSources = @ProjectConfiguration.GetExtendedSources()
      extendedSources.each do |source|
        binaryPath = GetBinaryFilePath(source)
        compileCommand = GetCompileCommand(source, binaryPath)
        @compiles.push(binaryPath)

        CreateFileTask({
          filePath: binaryPath,
          dependencies: extendedHeaders + [source, @ProjectConfiguration.GetFinalCompilesDirectory(), @ProjectConfiguration.GetFinalBuildDirectory()],
          command: compileCommand,
          error: "Failed to compile #{source}"
        })
      end
    end

    # Creates the compiler command that is used to link the compiled sources.
    def CreateLinkTask
      @binaryFileName = @ProjectConfiguration.GetFinalBuildDirectory()
      if(@ProjectConfiguration.BinaryType == :application)
        @binaryFileName = JoinPaths([@binaryFileName, @ProjectConfiguration.BinaryName])
        command = "g++ -o #{@binaryFileName} #{@linkOptionDirective} #{@definesDirective} #{@linkCompilesDirective} #{@libraryDirective}"
      elsif(@ProjectConfiguration.BinaryType == :shared)
        @binaryFileName = JoinPaths([@binaryFileName, "lib#{@ProjectConfiguration.BinaryName}.so"])
        command = "g++ -shared -fPIC -o #{@binaryFileName} #{@linkOptionDirective} #{@definesDirective} #{@linkCompilesDirective} #{@libraryDirective}"
      else
        @binaryFileName = JoinPaths([@binaryFileName, "lib#{@ProjectConfiguration.BinaryName}.a"])
        command = "ar cq #{@binaryFileName} #{@linkCompilesDirective}"
      end

      CreateFileTask({
        filePath: @binaryFileName,
        dependencies: @compiles + @Dependencies,
        command: command,
        error: "Failed to link #{@ProjectConfiguration.BinaryName}"
      })

      @EndTask = @binaryFileName
      
      CreateLibraryCopyTasks()
    end
    
    def CreateLibraryCopyTasks()
       # Copy libraries and their headers into binary directory
      @ProjectConfiguration.Libraries.each do |libContainer|
	if(!libContainer.UsedInLinux() or libContainer.IsStatic())
	  next
	end
	  
        fullLibraryPath = libContainer.GetFullCopyFilePath(:Linux)
        
        if(fullLibraryPath)
          #puts "copy lib #{fullLibraryPath}"
          copyPath = JoinPaths( [@ProjectConfiguration.GetFinalBuildDirectory(), libContainer.GetCopyFileName(:Linux) ] )

          CreateFileTask({
            filePath: copyPath,
            dependencies: fullLibraryPath,
            command: "cp #{fullLibraryPath} #{copyPath}"
          })

          CreateFileTask({
            filePath: @EndTask,
            dependencies: copyPath
          })
        end
      end
    end

    def GetCompileCommand(extendedSource, binaryPath)
      if(@ProjectConfiguration.BinaryType == :shared or @ProjectConfiguration.BinaryType == :static)
        return "g++ -fPIC -c #{@compilerOptionDirective} #{@includeDirectoryDirective} #{@definesDirective} -o #{binaryPath} #{extendedSource}"
      else
        return "g++ -c #{@compilerOptionDirective} #{@includeDirectoryDirective} #{@definesDirective} -o #{binaryPath} #{extendedSource}"
      end
    end

    def GetBinaryFilePath(extendedSource)
      filename = File.basename(extendedSource, ".cpp")
      return JoinPaths( [ @ProjectConfiguration.GetFinalCompilesDirectory(), "#{filename}.o" ]);
    end

    # Creates a string containing all include directories for the project.
    def CreateIncludeDirectoryDirective
      includeTree = @ProjectConfiguration.GetIncludeDirectoryTree()
      includeTree.concat(@ProjectConfiguration.GetLibraryIncludePaths(:Linux))

      @DependencyCompileOrders.each do |compileOrder|
        
        if(compileOrder.class.name == GppExistingCompileOrder.name)
          compileOrder.SyncToOriginal()
        end
        includeTree.concat(compileOrder.ProjectConfiguration.GetIncludeDirectoryTree())
        includeTree.concat(compileOrder.ProjectConfiguration.GetLibraryIncludePaths(:Linux))
      end

      for i in 0..includeTree.length-1
        includeTree[i] = "-I#{includeTree[i]}"
      end

      @includeDirectoryDirective = includeTree.join(" ")
    end

    # Creates a string containing all the options for the compile step.
    def CreateCompilerOptionDirective
      @compilerOptionDirective = @CompilerOptions.join(" ")
    end

    # Creates a string containing all the options for the link step.
    def CreateLinkOptionDirective
      @linkOptionDirective = @LinkOptions.join(" ")
    end

    # Creates a string that can be handed to the compiler containing all the compiled source files that should be linked.
    def CreateLinkCompilesDirective
      @linkCompilesDirective = @compiles.join(" ")
    end

    def CreateLinkLibrariesDirective
      dynamicLibsSearchPaths = Set.new
      dynamicLibs = []
      staticLibs = []

      @ProjectConfiguration.Libraries.each do |libContainer|
        if(!libContainer.UsedInLinux())
          next
        end

        if(!libContainer.IsStatic())
	  libDirective = _GetDynamicLibraryDirective(libContainer)
	  if(libDirective)
	    dynamicLibs.push(libDirective)
	  end
	  
	  libSearchDirective = _GetDynamicLibrarySearchPathDirective(libContainer)
	  if(libSearchDirective)
	    dynamicLibsSearchPaths.add(libSearchDirective)
	  end
        else
	  libDirective = _GetStaticLibraryDirective(libContainer)
	  if(libDirective)
	    staticLibs.push(libDirective)
	  end
        end
      end

      dynamicLibsSearchPathsDirective = ""
      dynamicLibsSearchPaths.each do |path|
        dynamicLibsSearchPathsDirective = "#{dynamicLibsSearchPathsDirective} #{path}"
      end
      dynamicLibsDirective = dynamicLibs.join(" ")
      staticLibsDirective = staticLibs.join(" ")
      
      @libraryDirective = "#{dynamicLibsSearchPathsDirective} #{dynamicLibsDirective} #{staticLibsDirective}"
    end

    def _GetDynamicLibrarySearchPathDirective(libContainer)
      if(!libContainer.GetLibraryPath(:Linux))
	return nil
      end
      
      return "-L#{libContainer.GetLibraryPath(:Linux)}"
    end

    def _GetDynamicLibraryDirective(libContainer)
      if(!libContainer.GetName(:Linux))
	return nil
      end
      
      return "-l#{libContainer.GetName(:Linux)}"
    end

    def _GetStaticLibraryDirective(libContainer)
      return libContainer.GetFullLinkFilePath(:Linux)
    end

    # Creates a string containing all the defines in the project configuration.
    def CreateDefinesDirective
      defines = @ProjectConfiguration.Defines.clone
      for i in 0..defines.length-1
        defines[i] = "-D#{defines[i]}"
      end

      @definesDirective = defines.join(" ")
    end

    # Create a file task.
    # [filePath] The path of the file that should be created.
    # [dependencies] Task on which the task depends.
    # [command] The command to execute in the task block.
    # [error] The error message if the command fails.
    # Additionally, one block is given that is essentially the block for the task.
    def CreateFileTask(paramBag)
      filePath = paramBag[:filePath]
      dependencies = paramBag[:dependencies]
      command = paramBag[:command]
      error = paramBag[:error] or ""

      if(!filePath)
        abort "No file path given for file task creation"
      end
      
      if(dependencies)
        file filePath => dependencies
      end

      if(command)
        file filePath do
          SystemWithFail(command, error)
        end
      end
    end
  end

end