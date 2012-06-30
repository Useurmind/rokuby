module Rokuby
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
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      defines.concat(@SourceFileSet.GatherDefines())
      defines.concat(@IncludeFileSet.GatherDefines())
      return defines
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
    
    # Join two source units to one new source unit.
    def +(other)
      if(other == nil)
        return Clone(self)
      end
      
      su = SourceUnitInstance.new()
      
      su.SourceFileSet = self.SourceFileSet + other.SourceFileSet
      su.IncludeFileSet = self.IncludeFileSet + other.IncludeFileSet
      su.Defines = (self.Defines + other.Defines).uniq()
      
      return su
    end
  end
end
