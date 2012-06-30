module Rokuby
  # Defines where a set of source code can be found.
  # [SourceFileSpec] The specification where the source files can be found.
  # [IncludeFileSpec] The specification where the include files can be found.
  class SourceUnitSpecification < InformationSpecification
    attr_accessor :SourceFileSpec
    attr_accessor :IncludeFileSpec
    
    def initialize(valueMap=nil)
      
      @SourceFileSpec = FileSpecification.new()
      @IncludeFileSpec = FileSpecification.new()
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @SourceFileSpec = Clone(original.SourceFileSpec)
      @IncludeFileSpec = Clone(original.IncludeFileSpec)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines      
      defines.concat(@SourceFileSpec.GatherDefines())
      defines.concat(@IncludeFileSpec.GatherDefines())      
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      sourceFileSpec = valueMap[:SourceFileSpec] || valueMap[:srcSpec]
      if(sourceFileSpec)
        @SourceFileSpec = sourceFileSpec
      end
      
      includeFileSpec = valueMap[:IncludeFileSpec] || valueMap[:inclSpec]
      if(includeFileSpec)
        @IncludeFileSpec = includeFileSpec
      end
    end
  end
end
