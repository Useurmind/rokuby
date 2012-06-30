module Rokuby
  # This class holds the information found through a specification.
  class VsProjectInstance < InformationInstance
    attr_accessor :ResourceFileSet
    attr_accessor :IdlFileSet
    
    def initialize(valueMap=nil)
      @ResourceFileSet = FileSet.new()
      @IdlFileSet = FileSet.new()
      
      super(valueMap)
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @ResourceFileSet = Clone(original.ResourceFileSet)
      @IdlFileSet = Clone(original.IdlFileSet)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      defines.concat(@ResourceFileSet.GatherDefines())
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      resourceFileSet = valueMap[:ResourceFileSet] || valueMap[:resFileSet]
      if(resourceFileSet)
        @ResourceFileSet = resourceFileSet
      end
      
      idlFileSet = valueMap[:IdlFileSet] || valueMap[:idlFileSet]
      if(idlFileSet)
        @IdlFileSet = idlFileSet
      end
    end
  end
end
