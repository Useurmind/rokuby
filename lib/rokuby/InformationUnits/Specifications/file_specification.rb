module Rokuby
  # This class presents a specification for a set of files.
  # [IncludePatterns] An array of regex patterns used to define file paths that belong to this file set.
  # [ExcludePatterns] An array of regex patterns used to define file paths that do NOT belong to this file set.
  # [SearchPaths] An array of project paths representing the search location for the files (searches recursively).
  class FileSpecification < InformationSpecification
    attr_accessor :IncludePatterns
    attr_accessor :ExcludePatterns
    attr_accessor :SearchPaths
    
    def initialize(valueMap=nil)
      @IncludePatterns = []
      @ExcludePatterns = []
      @SearchPaths = []      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @IncludePatterns = Clone(original.IncludePatterns)
      @ExcludePatterns = Clone(original.ExcludePatterns)
      @SearchPaths = Clone(original.SearchPaths)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      defines = @Defines
      return defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      includePatterns = valueMap[:IncludePatterns] || valueMap[:inPats]
      if(includePatterns)
        @IncludePatterns.concat(includePatterns)
      end
      
      excludePatterns = valueMap[:ExcludePatterns] || valueMap[:exPats]
      if(excludePatterns)
        @ExcludePatterns.concat(excludePatterns)
      end
      
      searchPaths = valueMap[:SearchPaths] || valueMap[:sPaths]
      if(searchPaths)
        @SearchPaths.concat(searchPaths)
      end
    end
    
    #def to_s
    #  val = ""
    #  val += "Include: #{@IncludePatterns}\n"
    #  val += "Exclude: #{@ExcludePatterns}\n"
    #  val += "Search Paths: #{@SearchPaths}\n"
    #end
  end
end
