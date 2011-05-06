require "rake"
require "rake/clean"
require "cpp_project_configuration"
require "general_utility"
require "directory_utility"
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
  # After the project tasks were created with CreateProjectTasks, the EndTask can be used to build the project.
  class GppCompileOrder
    include GeneralUtility
    include DirectoryUtility

    attr_accessor :CompilerOptions
    attr_accessor :LinkOptions
    attr_accessor :ProjectConfiguration    
    attr_accessor :EndTask
    attr_accessor :Dependencies

    def initialize      
      @CompilerOptions = []
      @LinkOptions = ["-Wl,-rpath='$ORIGIN/lib'"] # relative linking of libraries
      @Dependencies = []

      @compiles = []
    end
    
    def initialize_copy(original)
      @CompilerOptions = Clone(original.CompilerOptions)
      @LinkOptions = Clone(original.LinkOptions)
      @ProjectConfiguration = Clone(original.ProjectConfiguration)
      
      @compiles = []
    end
  
    # Create all the necessary tasks to build the project.
    # After this operation was called the EndTask can be used to build the project.
    def CreateProjectTasks      
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
      #       file @ProjectConfiguration.CompilesDirectory do
      # 	command = "mkdir #{@ProjectConfiguration.CompilesDirectory}"
      # 	SystemWithFail(command, "Failed to create directory for binary files")
      #       end
    end
    
    # Create one compiler command for the compilation of each source in the project.
    def CreateCompileTasks
      extendedHeaders = @ProjectConfiguration.GetExtendedIncludes()
      extendedSources = @ProjectConfiguration.GetExtendedSources()
      extendedSources.each { |source|
        binaryPath = GetBinaryFilePath(source)
        compileCommand = GetCompileCommand(source, binaryPath)
        @compiles.push(binaryPath)

        #         puts "task #{binaryPath} => #{(extendedHeaders+[source]).to_s()}"
        file binaryPath => extendedHeaders + @Dependencies + [source, @ProjectConfiguration.GetFinalCompilesDirectory(), @ProjectConfiguration.GetFinalBuildDirectory()] do
          SystemWithFail(compileCommand, "Failed to compile #{source}")
        end
      }
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
      #       puts "task #{@ProjectConfiguration.BinaryName} => #{@compiles}"
      
      file @binaryFileName => @compiles do
        SystemWithFail("#{command}", "Failed to link #{@ProjectConfiguration.BinaryName}")
      end

      @EndTask = @binaryFileName
      
      CreateLibraryAndHeaderCopyTasks()
	
	#Copy headers into binary directory
	
    end
    
    def CreateLibraryAndHeaderCopyTasks()
       # Copy libraries and their headers into binary directory
      @ProjectConfiguration.Libraries.each do |libContainer|
	  if(!libContainer.UsedInLinux())
	    next
	  end
	  
	  CreateHeaderCopyTasks(libContainer)
	  
	  fullLibraryPath = libContainer.GetFullPath(:Linux)
	  copyPath = JoinPaths( [@ProjectConfiguration.GetFinalBuildDirectory(), libContainer.GetFileName(:Linux) ] )
	  
	  puts "#{copyPath} => #{@binaryFileName}"
	  file copyPath => fullLibraryPath do
	    SystemWithFail("cp #{fullLibraryPath} #{copyPath}")
	  end
	  file @EndTask => copyPath
	end
    end
    
    # Create tasks that copy the headers of a library into a subdir of the build directory
    def CreateHeaderCopyTasks(libContainer)
      fullHeaderNames = libContainer.GetFullHeaderNames(:Linux)
      
      baseIncludeDir = JoinPaths( [@ProjectConfiguration.GetFinalBuildDirectory(), "include", libContainer.GetName(:Linux) ] )
      
      fullHeaderNames.each do |header|
	
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
      
      # Get the complete directory tree recursivly
      @ProjectConfiguration.Libraries.each do |libContainer|
        if(!libContainer.UsedInLinux())
          next
        end
        # 	if(IsProjectSubdirectory(directory, @ProjectConfiguration.ProjectDirectory))
        # 	  puts "Adding subdirectory tree of #{directory}"
        # 	  includeTree = includeTree + GetDirectoryTree(directory)
        # 	elsif
        # 	  puts "Adding directory #{directory}"
        includeTree.concat(libContainer.GetHeaderPaths(:Linux))
        # 	end
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
        if(libContainer.UsedInLinux())
          next
        end

        if(libContainer.IsStatic())
          dynamicLibs.push(_GetDynamicLibraryDirective(libContainer))
          dynamicLibsSearchPaths.add(_GetDynamicLibrarySearchPathDirective(libContainer))
        else
          staticLibs.push(_GetStaticLibraryDirective(libContainer))
        end
      end

      dynamicLibsSearchPaths.each do |path|
        dynamicLibsSearchPathsDirective += " #{path}"
      end
      dynamicLibsDirective = dynamicLibs.join(" ")
      staticLibsDirective = staticLibs.join(" ")

      @libraryDirective = "#{dynamicLibsDirective} #{dynamicLibsDirective} #{staticLibsDirective}"
    end

    def _GetDynamicLibrarySearchPathDirective(libContainer)
      return "-L#{libContainer.GetLibraryPath(:Linux)}"
    end

    def _GetDynamicLibraryDirective(libContainer)
      return "-l#{libContainer.GetName(:Linux)}"
    end

    def _GetStaticLibraryDirective(libContainer)
      return libContainer.GetFullPath(:Linux)
    end

    # Creates a string containing all the defines in the project configuration.
    def CreateDefinesDirective
      defines = @ProjectConfiguration.Defines.clone
      for i in 0..defines.length-1
        defines[i] = "-D#{defines[i]}"
      end

      @definesDirective = defines.join(" ")
    end
  end

end
