module RakeBuilder
  class GppProjectCreator < Processor
    include GppProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end
    
    def _ProcessInputs(taskArgs=nil)
      _SortInputs()
      
      gppProject = GppProject.new()
      
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
