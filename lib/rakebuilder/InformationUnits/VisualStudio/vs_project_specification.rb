module RakeBuilder
  # This class holds additional specifications for information needed to create
  # a visual studio project.
  class VsProjectSpecification < InformationSpecification
    attr_accessor :ResourceFileSpec
    
    def initialize(valueMap=nil)
      @ResourceFileSpec = FileSpecification.new()
      
      super(valueMap)
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @ResourceFileSpec = Clone(original.ResourceFileSpec)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      defines.concat(@ResourceFileSpec.GatherDefines())
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      resourceFileSpec = valueMap[:ResourceFileSpec] || valueMap[:resSpec]
      if(resourceFileSpec)
        @ResourceFileSpec = resourceFileSpec
      end
    end
  end
end
