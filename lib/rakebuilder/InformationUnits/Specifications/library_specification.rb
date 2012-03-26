module RakeBuilder
  # This class defines all information about a library to clearly define to which
  # configuration it belongs and where it can be found.
  # [Name] The name of the library this specification belongs to.
  # [Location] The library file spec that defines where the library can be found.
  # [Platforms] The platforms for which this library is meant.
  class LibrarySpecification < InformationSpecification
    attr_accessor :Name
    attr_accessor :Platforms
    attr_accessor :Location
    
    def initialize(valueMap=nil)
      @Name = ""
      @Location = LibraryLocationSpec.new()
      @Platforms = []
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @Name = Clone(original.Name)
      @Location = Clone(original.Location)
      @Platforms = Clone(original.Platforms)
    end

    def IsForTargetPlatform(targetPlatform)
      isForPlatform = false
      @Platforms.each() do |platform|
        if(platform <= targetPlatform)
          isForPlatform = true
          break
        end
      end
      return isForPlatform
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      defines.concat(@Location.GatherDefines())
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      name = valueMap[:Name] || valueMap[:name]
      if(name)
        @Name = name
      end
      
      platforms = valueMap[:Platforms] || valueMap[:plats]
      if(platforms)
        @Platforms.concat(platforms)
      end
      
      location = valueMap[:Location] || valueMap[:loc]
      if(location)
        @Location = location
      end
    end
  end
end
