module RakeBuilder
  # This class holds the information found through a specification.
  class VSProjectSpecification < InformationInstance
    attr_accessor :ResourceFileSet
    
    def initialize
      super
      
      @ResourceFileSet = FileSet.new()
    end
    
    def initialize_copy(original)
      super(original)
      
      @ResourceFileSet = Clone(original.ResourceFileSet)
    end
  end
end
