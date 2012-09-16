module Rokuby

  # This class includes a set of libraries that should be bundeled.
  # It contains several LibrarySpecifications that together form a set of specifications
  # for different versions of libraries.
  # [Specifications] The different library versions that are bundeled into this set.
  class LibrarySpecificationSet < InformationSpecification
    attr_accessor :Specifications
    
    def initialize(valueMap=nil)
      @Specifications = []
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @Specifications = Clone(original.Specifications)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      specifications = valueMap[:Specifications] || valueMap[:specs]
      if(specifications)
        @Specifications = @Specifications + specifications
      end
    end
  end

end
