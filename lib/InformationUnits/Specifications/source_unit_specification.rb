module RakeBuilder
  # Defines where a set of source code can be found.
  # [SourceFileSpec] The specification where the source files can be found.
  # [IncludeFileSpec] The specification where the include files can be found.
  class SourceUnitSpecification < InformationSpecification
    attr_accessor :SourceFileSpec
    attr_accessor :IncludeFileSpec
    
    def initialize
      super
      
      @SourceFileSpec = FileSpecification.new()
      @IncludeFileSpec = FileSpecification.new()
    end
    
    def initialize_copy(original)
      super(original)
      
      @SourceFileSpec = Clone(original.SourceFileSpec)
      @IncludeFileSpec = Clone(original.IncludeFileSpec)
    end
  end
end
