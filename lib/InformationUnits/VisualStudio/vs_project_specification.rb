module RakeBuilder
  # This class holds additional specifications for information needed to create
  # a visual studio project.
  class VSProjectSpecification < InformationSpecification
    attr_accessor :ResourceFileSpec
    
    def initialize(valueMap=nil)
      super(valueMap)
      
      @ResourceFileSpec = FileSpecification.new()
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @ResourceFileSpec = Clone(original.ResourceFileSpec)
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
