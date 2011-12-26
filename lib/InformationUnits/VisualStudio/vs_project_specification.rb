module RakeBuilder
  # This class holds additional specifications for information needed to create
  # a visual studio project.
  class VSProjectSpecification < InformationSpecification
    attr_accessor :ResourceFileSpec
    
    def initialize
      super
      
      @ResourceFileSpec = FileSpecification.new()
    end
    
    def initialize_copy(original)
      super(original)
      
      @ResourceFileSpec = Clone(original.ResourceFileSpec)
    end
  end
end
