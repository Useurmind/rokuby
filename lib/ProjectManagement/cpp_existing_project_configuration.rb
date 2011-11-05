module RakeBuilder
  # A class that enables the use of project configurations of a subproject that is contained in a subfolder of the current project.
  # This is practical when compilation of a subproject is needed that also uses the RakeBuilder.
  # It essentially prepends the subfolder of the subproject to all paths where this is necessary.
  class CppExistingProjectConfiguration < CppProjectConfiguration
    attr_accessor :OriginalConfiguration
    attr_accessor :Subfolder
    
    # [projectConfiguration] The existing project configuration.
    # [folder] The subfolder where the existing project configuration is valid.
    def initialize(paramBag)
      @OriginalConfiguration = paramBag[:projectConfiguration]
      @Subfolder = paramBag[:folder]

      InitCopy(@OriginalConfiguration)

      @ProjectDirectory = JoinPaths([ @Subfolder, @ProjectDirectory ])
      
      AdaptLibraryPaths()

      puts "Initialized new subproject with subfolder '#{@ProjectDirectory}'"
    end

    def AdaptLibraryPaths()
      newLibs = []
      @Libraries.each do |libContainer|
        if(!libContainer.UsedInLinux())
          next
        end
        
        newLibContainer = Clone(libContainer)

        lib = newLibContainer.GetLibraryForOs(:Linux)
        lib.LibraryPath = GetExecutingDirectoryRelativePath(lib.LibraryPath)
        for i in 0..lib.HeaderPaths.length-1
          lib.HeaderPaths[i] = GetExecutingDirectoryRelativePath(lib.HeaderPaths[i])
        end
        
        newLibs.push(newLibContainer)
      end
      @Libraries = newLibs
    end
  end
end