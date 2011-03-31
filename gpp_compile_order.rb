require "rake"
require "rake/clean"
require "cpp_project_configuration"
require "general_utility"
require "directory_utility"

module RakeBuilder

  # This class will create the necessary tasks to compile a cpp project with the gpp.
  # [CompilerOptions] The options that the compiler needs to compile the sources of this project.
  # [LinkOptions] The options that the compiler needs to link the compiled sources of this project.
  # [ProjectConfiguration] This is the configuration for the C++ project that includes all the information about the project.
  # [LibrarySearchPaths] The paths to search for libraries (default: [ "/usr/lib", "usr/local/lib" ])
  # [LibraryIncludeDirectories] The paths were the headers of the different libraries are located (default: [ "/usr/include" , "usr/locale/include" ])
  # [EndTask] This is the task that can be used to create dependencies between the creation of this project and other tasks.
  class GppCompileOrder
    include GeneralUtility
    include DirectoryUtility

    attr_accessor :CompilerOptions
    attr_accessor :LinkOptions
    attr_accessor :ProjectConfiguration    
    attr_accessor :LibrarySearchPaths
    attr_accessor :LibraryIncludeDirectories
    attr_accessor :EndTask

    def initialize      
      @CompilerOptions = []
      @LinkOptions = []
      @LibrarySearchPaths = [ "/usr/lib", "/usr/local/lib" ]
      @LibraryIncludeDirectories = [ "/usr/include" , "/usr/locale/include" ]
      
      @compiles = []
    end
    
    def initialize_copy(original)
      @CompilerOptions = Clone(original.CompilerOptions)
      @LinkOptions = Clone(original.LinkOptions)
      @LibrarySearchPaths = Clone(original.LibrarySearchPaths)
      @LibraryIncludeDirectories = Clone(original.LibraryIncludeDirectories)
      @ProjectConfiguration = Clone(original.ProjectConfiguration)
      
      @compiles = []
    end
  
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
        CLEAN.include(@compiles)
	CLEAN.include(@ProjectConfiguration.BinaryName)
    end

    # Create a task to create the directory for the binaries that are compiled
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
        file binaryPath => extendedHeaders + [source, @ProjectConfiguration.GetFinalCompilesDirectory(), @ProjectConfiguration.GetFinalBuildDirectory()] do
          SystemWithFail(compileCommand, "Failed to compile #{source}")
        end
      }
    end

    # Creates the compiler command that is used to link the compiled sources.
    def CreateLinkTask
      @binaryFileName = @ProjectConfiguration.GetFinalBuildDirectory()
      if(@ProjectConfiguration.BinaryType == :application)
	@binaryFileName = JoinPaths([@binaryFileName, @ProjectConfiguration.BinaryName])
	command = "g++ -o #{@binaryFileName} #{@linkOptionDirective} #{@definesDirective} #{@linkCompilesDirective} #{@linkLibrariesDirective}" 
      elsif(@ProjectConfiguration.BinaryType == :shared)
	@binaryFileName = JoinPaths([@binaryFileName, "lib#{@ProjectConfiguration.BinaryName}.so"])
	command = "g++ -shared -fPIC -o #{@binaryFileName} #{@linkOptionDirective} #{@definesDirective} #{@linkCompilesDirective} #{@linkLibrariesDirective}" 
      else
	@binaryFileName = JoinPaths([@binaryFileName, "lib#{@ProjectConfiguration.BinaryName}.a"])
	command = "ar cq #{@binaryFileName} #{@linkCompilesDirective}" 
      end
#       puts "task #{@ProjectConfiguration.BinaryName} => #{@compiles}"
      file @binaryFileName => @compiles do
        SystemWithFail(command, "Failed to link #{@ProjectConfiguration.BinaryName}")
      end

      @EndTask = @binaryFileName
    end

    def GetCompileCommand(extendedSource, binaryPath)
      if(@ProjectConfiguration.BinaryType == :shared)
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
      
      @LibraryIncludeDirectories.each do |directory|
	includeTree.push(directory)
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
    
    # Creates a string that can be handed to the compiler containing all the libraries to link in
    def CreateLinkLibrariesDirective
      searchPaths = @LibrarySearchPaths
      for i in 0..searchPaths.length-1 do
	searchPaths[i] = "-L#{searchPaths[i]}"
      end	
      searchPathDirective = searchPaths.join(" ")
      
      staticLibs = @ProjectConfiguration.StaticLibraries
      for i in 0..staticLibs.length-1 do
	staticLibs[i] = "lib#{staticLibs[i]}.a"
      end
      staticLibDirective = staticLibs.join(" ")
      
      dynamicLibs = @ProjectConfiguration.DynamicLibraries
      for i in 0..dynamicLibs.length-1 do
	dynamicLibs[i] = "-l#{dynamicLibs[i]}"
      end
      dynamicLibDirective = dynamicLibs.join(" ")
      
      @linkLibrariesDirective = "#{searchPathDirective} #{staticLibDirective} #{dynamicLibDirective}"
    end

    # Creates a string containing all the defines in the project configuration.
    def CreateDefinesDirective
      defines = @ProjectConfiguration.Defines
      for i in 0..defines.length-1
        defines[i] = "-D#{defines[i]}"
      end

      @definesDirective = defines.join(" ")
    end
  end

end
