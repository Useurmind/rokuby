module RakeBuilder
  # This class holds meta information about a project needed in visual studio.
  # [ProjectFilePath] The path of the project file.
  # [FilterFilePath] The path of the filter file.
  # [Guid] A unique UUID of the project in the form '{45CD...}'.
  # [RootNamespace] The root namespace of the project.
  class VSProjectDescription < InformationUnit
    attr_accessor :ProjectFilePath
    attr_accessor :FilterFilePath
    attr_accessor :Guid
    attr_accessor :RootNamespace
    
    def initialize
      super
      
      # filled by the project builde processor if not set
      @ProjectFilePath = nil
      @FilterFilePath = nil
      
      @Guid = GetUUID()
      @RootNamespace = ""
    end
    
    def initialize_copy(original)
      super(original)
      
      @ProjectFilePath = Clone(original.ProjectFilePath)
      @FilterFilePath = Clone(original.FilterFilePath)
      @Guid = Clone(original.Guid)
      @RootNamespace = Clone(original.RootNamespace)
    end
  end
end
