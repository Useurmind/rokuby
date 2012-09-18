module Rokuby
  # Symbols that describe different solution builder types
  SOLUTION_BUILDER_TYPES = [
    :Vs,  # A solution for visual studio
  ]
  
  # This class is the basis for multi platform solution builds.
  # It is a simple processor array with a special extend function to allow
  # for better configurability.
  # The extend function allows for one further argument.
  # [ProcessorTypes or procTypes] Contains types of solution builders that should be
  #                               available in the processor array according to SOLUTION_BUILDER_TYPES.
  class MultiSolutionBuilder < ProcessorArray
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
        vsName = (Name().to_s() + "_Vs").to_sym()
        vsSlnBuild vsName
        valueMap[:arrProcs][:Vs] = vsName
      end  
      
      super(valueMap)
    end
  end
end
