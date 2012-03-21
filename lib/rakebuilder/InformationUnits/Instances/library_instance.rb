module RakeBuilder
  # This class represents an instance of a library used on a certain plaform.
  # [FileSet] The set of files that belong to this specific library.
  # [Platforms] The platforms that this library instance is for.
  class LibraryInstance < InformationInstance
    attr_accessor :FileSet
    attr_accessor :Platforms
    
    def initialize(valueMap=nil)
      @FileSet = LibraryFileSet.new()
      @Platforms = []
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @FileSet = Clone(original.FileSet)
      @Platforms = Clone(original.Platforms)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      defines.concat(@FileSet.GatherDefines())
      return defines
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
      
      platforms = valueMap[:Platforms] || valueMap[:plats]
      if(platforms)
        @Platforms = platforms
      end
    end
  end
end
