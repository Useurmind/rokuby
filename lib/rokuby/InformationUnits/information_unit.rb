module Rokuby
  # An information unit is a unit of information that flows through the build process.
  class InformationUnit
    include GeneralUtility
    
    def initialize(valueMap)
      super()
      Extend(valueMap, false)
    end
    
    # This function is used to set attributes of the information unit.
    # The hash is given as a set of key, value pairs with the key being the name of an attribute and the value being the new
    # value for the attribute. The names of the attributes can also be abbreviated, this should be stated by the single information
    # units.
    # @param [Hash] valueMap A hash containing the attribute names and values for the attributes that should be set.
    # @param [true, false] callParent Should the extend method of the parent be called before the own Extend call is executed.    
    def Extend(valueMap, callParent=true)
      
    end
  end
end
