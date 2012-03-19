module RakeBuilder
  # This class is responsible for building a library instance of the project that
  # can be reused in other projects.
  class VsProjectLibraryCreator < Processor
    include VsProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      _CreateLibrary()
      @outputs = [@library]
    end
    
    def _CreateLibrary
      @library = Library.new()
      
      @vsProjectConfigurations.each() do |vsConfig|
        config = _GetProjectConfiguration(vsConfig)
        
        if(vsConfig.ConfigurationType == VS::Configuration::ConfigurationType::APPLICATION)
          next
        end
        
        libName = ProjectPath.new(vsConfig.TargetName + VS::Configuration::TargetEx::STATIC)
        linkName = ProjectPath.new(vsConfig.TargetName + vsConfig.TargetExt)
        libPath = vsConfig.OutputDirectory
        
        includeFileSet = nil
        @vsProjectInstance.SourceUnits.each() do |su|
          if(includeFileSet == nil)
            includeFileSet = su.IncludeFileSet
          else
            includeFileSet = includeFileSet + su.IncludeFileSet
          end
        end
        
        libInstance = LibraryInstance.new()
        libInstance.Platform = vsConfig.Platform
        libInstance.FileSet.LibraryFileSet.FilePaths = libPath + libName
        libInstance.FileSet.LibraryFileSet.FileDirectories = [libPath]
        libInstance.FileSet.LibraryFileSet.RootDirectories = [ProjectPath.new(".")]
        libInstance.FileSet.LinkFileSet.FilePaths = libPath + linkName
        libInstance.FileSet.LinkFileSet.FileDirectories = [libPath]
        libInstance.FileSet.LinkFileSet.RootDirectories = [ProjectPath.new(".")]
        libInstance.FileSet.IncludeFileSet = includeFileSet
        
        @library.AddInstance(libInstance)
      end
    end
    
    def _GetProjectConfiguration(vsConfig)
      @projectConfigurations.each() do |config|
        if(config.Platform == vsConfig.Platform)
          return config
        end
      end
      
      raise "Could not find matching projcet configuration to visual studio project configuration in #{self.class.name}"
    end
  end
end
