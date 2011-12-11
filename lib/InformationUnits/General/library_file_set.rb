module RakeBuilder
  # This class contains all files belonging to a single library.
  # [LibraryFileSet] A file set containing the libary file.
  # [LinkFileSet] A file set containing the file that should be linked to.
  # [IncludeFileSet] A file set containing the include files for the library.
  class LibraryFileSet < InformationUnit
    attr_accessor :LibraryFileSet
    attr_accessor :LinkFileSet
    attr_accessor :IncludeFileSet
    
    # Get the first file path that was found matching the description for the library.
    def LibraryFilePath      
      if(!@LibraryFileSet.FilePaths.length > 0)
        throw "No library files found for library"
      end
      return @LibraryFileSet.FilePaths[0]
    end
    
    # Get the file name of the library that was found.
    def LibraryFileName
      libraryPath = LibraryFilePath()
      if(!libraryPath.filePath?)
        throw "Library path is no file path"
      end
      libraryPath.FileName
    end
    
    # Get the path to the file that should be linked.
    def LinkFilePath      
      if(!@LinkFileSet.FilePaths.length > 0)
        throw "No library files found for library"
      end
      return @LinkFileSet.FilePaths[0]
    end
    
    # Get the name of the file that should be linked.
    def LinkFileName
      LinkFilePath().FileName
    end
    
    # The project paths where includes were found.
    def IncludePaths
      @IncludeFileSet.FileDirectories()
    end
    
    # The project paths of all include files that were found.
    def IncludeFiles
      @IncludeFileSet.FilePaths()
    end
    
    def initialize()
      @LibraryFileSet = FileSet.new()
      @LinkFileSet = FileSet.new()
      @IncludeFileSet = FileSet.new()
    end
    
    def initialize_copy(original)
      @LibraryFileSet = Clone(original.LibraryFileSet)
      @LinkFileSet = Clone(original.LinkFileSet)
      @IncludeFileSet = Clone(original.IncludeFileSet)
    end
  end
end
