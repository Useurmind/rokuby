module RakeBuilder
  # This class represents an instance of a library used on a certain plaform.
  # [FileSet] The set of files that belong to this specific library.
  # [Platform] The platform that this library instance is for.
  class LibraryInstance < InformationInstance
    attr_accessor :FileSet
    attr_accessor :Platform
    
    def initialize(valueMap=nil)
      super(valueMap)
      @FileSet = FileSet.new()
      @Platform = PlatformConfiguration.new()
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @FileSet = Clone(original.FileSet)
      @Platform = Clone(original.Platform)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      fileSet = valueMap[:FileSet] || valueMap[:fileSet]
      if(fileSet)
        @FileSet = fileSet
      end
      
      platform = valueMap[:Platform] || valueMap[:plat]
      if(platform)
        @Platform = platform
      end
    end
  end
end
