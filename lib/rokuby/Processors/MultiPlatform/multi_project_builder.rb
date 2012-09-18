module Rokuby
  # Symbols that describe different project builder types
  PROJECT_BUILDER_TYPES = [
    :Vs,  # A project for visual studio
    :Gpp  # A project for the gpp compiler
  ]
  
  # This class is the basis for multi platform project builds.
  # It is a simple processor array with a special extend function to allow
  # for better configurability.
  # The extend function allows for one further argument.
  # [ProcessorTypes or procTypes] Contains types of project builders that should be
  #                               available in the processor array according to PROJECT_BUILDER_TYPES.
  class MultiProjectBuilder < ProcessorArray
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
        vsProjBuild vsName
        valueMap[:arrProcs][:Vs] = vsName
      end
      
      if(procTypes.include?(:Gpp))
        gppName = (Name().to_s() + "_Gpp").to_sym()
        gppProjBuild gppName
        valueMap[:arrProcs][:Gpp] = gppName
      end      
      
      super(valueMap)
    end
  end
end
