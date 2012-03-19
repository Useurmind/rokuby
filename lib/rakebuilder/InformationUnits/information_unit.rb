module RakeBuilder
  # An information unit is a unit of information that flows through the build process.
  class InformationUnit
    include GeneralUtility
    
    def initialize(valueMap)
      super()
      Extend(valueMap, false)
    end
    
    # This function is used to set values on the information unit.
    # Usually, this function should push/concat new values to arrays, set new keys
    # on hashs or overwrite elementary values.
    def Extend(valueMap, callParent=true)
      
    end
  end
end
