module RakeBuilder
  # Describes a set of source code.
  # [SourceFileSet] The file set that includes the source files that should be compiled.
  # [IncludeFileSet] The file set that includes the header files that belong to the compilation unit.
  class SourceUnitInstance < InformationInstance
    attr_accessor :SourceFileSet
    attr_accessor :IncludeFileSet
    
    def initialize(valueMap=nil)
      @Defines = []
      @SourceFileSet = FileSet.new()
      @IncludeFileSet = FileSet.new()
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @Defines = Clone(original.Defines)
      @SourceFileSet = Clone(original.SourceFileSet)
      @IncludeFileSet = Clone(original.IncludeFileSet)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      sourceFileSet = valueMap[:SourceFileSet] || valueMap[:srcFileSet]
      if(sourceFileSet)
        @SourceFileSet = sourceFileSet
      end
      
      includeFileSet = valueMap[:IncludeFileSet] || valueMap[:inclFileSet]
      if(includeFileSet)
        @IncludeFileSet = includeFileSet
      end
    end
  end
end
