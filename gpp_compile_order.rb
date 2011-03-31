require "rake"
require "rake/clean"
require "cpp_project_configuration"
require "general_utility"

module RakeBuilder

  # This class will create the necessary tasks to compile a cpp project with the gpp.
  # [CompilerOptions] The options that the compiler needs to compile the sources of this project.
  # [LinkOptions] The options that the compiler needs to link the compiled sources of this project.
  # [ProjectConfiguration] This is the configuration for the C++ project that includes all the information about the project.
  # [EndTask] This is the task that can be used to create dependencies between the creation of this project and other tasks.
  class GppCompileOrder
    include GeneralUtility

    attr_accessor :CompilerOptions
    attr_accessor :LinkOptions
    attr_accessor :ProjectConfiguration
    attr_accessor :EndTask

    def initialize
      @CompilerOptions = []
      @LinkOptions = []
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
      directory @ProjectConfiguration.CompilesDirectory
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
        file binaryPath => extendedHeaders + [source, @ProjectConfiguration.CompilesDirectory] do
          SystemWithFail(compileCommand, "Failed to compile #{source}")
        end
      }
    end

    # Creates the compiler command that is used to link the compiled sources.
    def CreateLinkTask
      command = "g++ -o #{@ProjectConfiguration.BinaryName} #{@linkOptionDirective} #{@definesDirective} #{@linkCompilesDirective}"
#       puts "task #{@ProjectConfiguration.BinaryName} => #{@compiles}"
      file @ProjectConfiguration.BinaryName => @compiles do
        SystemWithFail(command, "Failed to link #{@ProjectConfiguration.BinaryName}")
      end

      @EndTask = @ProjectConfiguration.BinaryName
    end

    def GetCompileCommand(extendedSource, binaryPath)
      return "g++ -c #{@compilerOptionDirective} #{@includeDirectoryDirective} #{@definesDirective} -o #{binaryPath} #{extendedSource}"
    end

    def GetBinaryFilePath(extendedSource)
      filename = File.basename(extendedSource, ".cpp")
      return "#{@ProjectConfiguration.CompilesDirectory}/#{filename}.o";
    end

    # Creates a string containing all include directories for the project.
    def CreateIncludeDirectoryDirective
      includeTree = @ProjectConfiguration.GetIncludeDirectoryTree()

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
