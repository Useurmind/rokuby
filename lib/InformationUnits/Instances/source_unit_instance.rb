module RakeBuilder
  # Describes a set of source code.
  # [SourceFileSet] The file set that includes the source files that should be compiled.
  # [IncludeFileSet] The file set that includes the header files that belong to the compilation unit.
  class SourceUnitInstance < InformationInstance
    attr_accessor :SourceFileSet
    attr_accessor :IncludeFileSet
    
    def initialize()
      super
      @Defines = []
      @SourceFileSet = FileSet.new()
      @IncludeFileSet = FileSet.new()
    end
    
    def initialize_copy(original)
      super(original)
      @Defines = Clone(original.Defines)
      @SourceFileSet = Clone(original.SourceFileSet)
      @IncludeFileSet = Clone(original.IncludeFileSet)
    end
  end
end
