module RakeBuilder
  # This class defines how the stuff needed for a project can be found.
  # [LibrarySpecs] The specifications for the libraries that should be used.
  # [SourceSpecs] The specifications for the source units that belong to this project.
  class ProjectSpecification < InformationSpecification
    attr_accessor :LibrarySpecs
    attr_accessor :SourceSpecs
    
    def initialize()
      super
      
      @LibrarySpecs = []
      @SourceSpecs = []
    end
    
    def initialize_copy(original)
      super(original)
      
      @LibrarySpecs = Clone(original.LibrarySpecs)
      @SourceSpecs = Clone(original.SourceSpecs)
    end
  end
end
