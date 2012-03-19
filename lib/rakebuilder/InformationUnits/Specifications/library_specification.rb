module RakeBuilder
  # This class defines all information about a library to clearly define to which
  # configuration it belongs and where it can be found.
  # [Name] The name of the library this specification belongs to.
  # [Location] The library file spec that defines where the library can be found.
  # [Platform] The platform for which this library is meant.
  class LibrarySpecification < InformationSpecification
    attr_accessor :Name
    attr_accessor :Platform
    attr_accessor :Location
    
    def initialize(valueMap=nil)
      @Name = ""
      @Location = LibraryLocationSpec.new()
      @Platform = PlatformConfiguration.new()
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @Name = Clone(original.Name)
      @Location = Clone(original.Location)
      @Platform = Clone(original.Platform)
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
      
      platform = valueMap[:Platform] || valueMap[:plat]
      if(platform)
        @Platform = platform
      end
      
      location = valueMap[:Location] || valueMap[:loc]
      if(location)
        @Location = location
      end
    end
  end
end
