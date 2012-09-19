module Rokuby
  class GppProjectCreator < Processor
    include GppProjectProcessorUtility
    include DirectoryUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end
    
    def _ProcessInputs(taskArgs=nil)
      #platBinExt = GetPlatformBinaryExtensions(taskArgs)
      
      _SortInputs()
      
      gppProject = GppProject.new()
      
      # gather include paths
      includePaths = []
      
      @projectInstance.SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |rootDir|
          includePaths.concat GetDirectoryTree(rootDir)
        end
      end
      
      includePaths = includePaths.uniq
      
      gppProject.Extend :Name => Clone(@projectDescription.Name),
                        :Configurations => Clone(@gppProjectConfigurations),
                        :Dependencies => Clone(@gppProjects),
                        :IncludePaths => includePaths,
                        :Libraries => @projectInstance.Libraries,
                        :PassedDefines => @passthroughDefines
      
      @outputs = [gppProject]
    end
  end
end
