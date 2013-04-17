module Rokuby
  
  
  class MultiDoxygenBuilder < ProcessorArray
    
    def _InitProc
      super()
      
      doxyBuilderName = @Name.to_s + "_DoxyBuilder"
      @DoxygenBuilder = doxyBuild doxyBuilderName.to_sym()
    end
    
    # Extend/set the attributes of the ProcessorArray.
    def Extend(valueMap, executeParent=true)
      #puts "in extend of process chain #{name}: #{valueMap}"
      if(valueMap == nil)
        return
      end
      
      procTypes = valueMap[:procTypes] || valueMap[:ProcessorTypes] || []      
      if(procTypes)
        valueMap[:arrProcs] = valueMap[:arrProcs] || {}
      end
      
      if(procTypes.include?(:Vs))
        valueMap[:arrProcs][:Vs] = @DoxygenBuilder.Name
      elsif(procTypes.include?(:Gpp))
        valueMap[:arrProcs][:Gpp] = @DoxygenBuilder.Name
      end
        
      super(valueMap)
    end
  end
end
