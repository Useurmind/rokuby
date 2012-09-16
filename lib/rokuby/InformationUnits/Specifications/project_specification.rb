module Rokuby
  # This class defines how the stuff needed for a project can be found.
  # [LibrarySpecs] The specifications for the libraries that should be used (can be LibrarySpecifications and LibrarySpecificationSets).
  # [SourceSpecs] The specifications for the source units that belong to this project.
  class ProjectSpecification < InformationSpecification
    attr_accessor :LibrarySpecs
    attr_accessor :SourceSpecs
    
    def initialize(valueMap=nil)
      
      @LibrarySpecs = []
      @SourceSpecs = []
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @LibrarySpecs = Clone(original.LibrarySpecs)
      @SourceSpecs = Clone(original.SourceSpecs)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      @LibrarySpecs.each() do |libSpec|
        defines.concat(libSpec.GatherDefines())      
      end

      @SourceSpecs.each() do |srcSpec|
        defines.concat(srcSpec.GatherDefines())      
      end

      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      librarySpecs = valueMap[:LibrarySpecs] || valueMap[:libSpecs]
      if(librarySpecs)
        @LibrarySpecs.concat(librarySpecs)
      end
      
      sourceSpecs = valueMap[:SourceSpecs] || valueMap[:srcSpecs]
      if(sourceSpecs)
        @SourceSpecs.concat(sourceSpecs)
      end
    end
  end
end
