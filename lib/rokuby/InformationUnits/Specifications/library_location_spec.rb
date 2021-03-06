module Rokuby
  # This class describes how a library instance can be found on a system.
  # [LibraryFileSpec] The file specification for the library file.
  # [LinkFileSpec] The file specification for the file that should be linked against.
  # [IncludeFileSpec] The file specification for the include files of the library.
  class LibraryLocationSpec < InformationSpecification
    attr_accessor :LibraryFileSpec
    attr_accessor :LinkFileSpec
    attr_accessor :IncludeFileSpec
    
    def initialize(valueMap=nil)
      @LibraryFileSpec = FileSpecification.new()
      @LinkFileSpec = FileSpecification.new()
      @IncludeFileSpec = FileSpecification.new()
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @LibraryFileSpec = Clone(original.LibraryFileSpec)
      @LinkFileSpec = Clone(original.LinkFileSpec)
      @IncludeFileSpec = Clone(original.IncludeFileSpec)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      defines.concat(@LibraryFileSpec.GatherDefines())
      defines.concat(@LinkFileSpec.GatherDefines())
      defines.concat(@IncludeFileSpec.GatherDefines())
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      libraryFileSpec = valueMap[:LibraryFileSpec] || valueMap[:libSpec]
      if(libraryFileSpec)
        @LibraryFileSpec = libraryFileSpec
      end
      
      linkFileSpec = valueMap[:LinkFileSpec] || valueMap[:linkSpec]
      if(linkFileSpec)
        @LinkFileSpec = linkFileSpec
      end
      
      includeFileSpec = valueMap[:IncludeFileSpec] || valueMap[:inclSpec]
      if(includeFileSpec)
        @IncludeFileSpec = includeFileSpec        
      end
    end
  end
end
