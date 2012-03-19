module RakeBuilder
  # This processor is responsible for creating a VSProject instance, which can be used
  # in other projects.
  # Inputs are all the project objects that describe the project and output is a
  # VSProject instance that represents the created project.
  class VsProjectCreator < Processor
    include VsProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @Project = nil
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      
      @Project = VsProject.new()
      
      puts "in ProjectCreator: #{[@vsProjectDescription]}"
      
      @Project.Extend :Name => Clone(@projectDescription.Name),
                      :Guid => Clone(@vsProjectDescription.Guid),
                      :ProjectFilePath => Clone(@vsProjectDescription.ProjectFilePath),
                      :FilterFilePath => Clone(@vsProjectDescription.FilterFilePath),
                      :Configurations => Clone(@vsProjectConfigurations),
                      :Dependencies => Clone(@vsProjects),
                      :BinaryFileSet => nil, # the binaries are determined through the configuration targetname and outputdirectory
                      :Libraries => @projectInstance.Libraries
                      
      
      @outputs = [@Project]
    end
  end
end
