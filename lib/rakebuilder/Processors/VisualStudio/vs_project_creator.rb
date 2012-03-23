module RakeBuilder
  # This processor is responsible for creating a VSProject instance, which can be used
  # in other projects.
  # Inputs are all the project objects that describe the project and output is a
  # VSProject instance that represents the created project.
  class VsProjectCreator < Processor
    include VsProjectProcessorUtility
    include DirectoryUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @Project = nil
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      
      if(@projectDescription == nil)
        raise "No ProjectDescription in #{self.class}:#{@Name}"
      end
      
      if(@vsProjectDescription == nil)
        raise "No VsProjectDescription in #{self.class}:#{@Name}"
      end
      
      if(@projectInstance == nil)
        raise "No ProjectInstance in #{self.class}:#{@Name}"
      end
      
      @Project = VsProject.new()
      
      #puts "in ProjectCreator: #{[@vsProjectDescription]}"
      
      includePaths = []
      @projectInstance.SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |rootDir|
          includePaths.concat GetDirectoryTree(rootDir)
        end        
      end
      includePaths = includePaths.uniq
      
      @Project.Extend :Name => Clone(@projectDescription.Name),
                      :Guid => Clone(@vsProjectDescription.Guid),
                      :ProjectFilePath => Clone(@vsProjectDescription.ProjectFilePath),
                      :FilterFilePath => Clone(@vsProjectDescription.FilterFilePath),
                      :Configurations => Clone(@vsProjectConfigurations),
                      :Dependencies => Clone(@vsProjects),
                      :IncludePaths => includePaths,
                      :Libraries => @projectInstance.Libraries,
                      :PassedDefines => @passthroughDefines
                      
      
      @outputs = [@Project]
    end
  end
end
