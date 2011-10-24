module RakeBuilder
  
  # Some file sets that represent a library file and headers for which should be searched.
  # Input Values:
  # [LibraryFileSet] A file set describing the libary file to search for.
  # [LinkFileSet] A file set describing the file that should be linked to.
  # [IncludeFileSet] A file set describing the include files for the library.
  # Output Values:
  # The output values of the input file sets.
  class LibraryBase < SystemInformationSet
    
    attr_accessor :LibraryFileSet
    attr_accessor :LinkFileSet
    attr_accessor :IncludeFileSet
    
    def LibraryFilePath      
      if(!@LibraryFileSet.FilePaths.length > 0)
        throw "No library files found for library"
      end
      return @LibraryFileSet.FilePaths[0]
    end
    
    def LibraryFileName
      LibraryFilePath().FileName
    end
    
    def LinkFilePath      
      if(!@LinkFileSet.FilePaths.length > 0)
        throw "No library files found for library"
      end
      return @LinkFileSet.FilePaths[0]
    end
    
    def LinkFileName
      LinkFilePath().FileName
    end
    
    def initialize
      @LibraryFileSet = FileSet.new()
      @LinkFileSet = FileSet.new()
      @IncludeFileSet = FileSet.new()
    end   
    
    def initialize_copy(original)
      @LibraryFileSet = Clone(original.LibraryFileSet)
      @LinkFileSet = Clone(original.LinkFileSet)
      @IncludeFileSet = Clone(original.IncludeFileSet)
    end
    
    # Fill the file sets that will contain the library and include files.
    def Fill
      @LibraryFileSet.Fill()
      @LinkFileSet.Fill()
      @IncludeFileSet.Fill()
    end
  end
  
end