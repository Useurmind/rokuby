module RakeBuilder
  
  # Some file sets that represent a specific library file and headers for which should be searched.
  # [Id] An id that describes this library.
  # [Os] The operating system for which this library is compiled.
  # [Architecture] The cpu archtitecture for which this library is compiled.
  # [Configuration] The name of a configuration for which this library is made (e.g. debug, release).
  # Input Values:
  # [LibraryFileSet] A file set describing the libary file to search for.
  # [LinkFileSet] A file set describing the file that should be linked to.
  # [IncludeFileSet] A file set describing the include files for the library.
  # Output Values:
  # The output values of the input file sets.
  class LibraryConfiguration < SystemInformationSet
    
    attr_accessor :Id
    
    attr_accessor :Os
    attr_accessor :Architecture
    attr_accessor :Configuration
    
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
    
    # All the attributes stated above.
    # [id] The id for the library.
    # [os] The os this library is for.
    # [arch] The cpu architecture this library is for.
    # [conf] The configuration this library is for.
    # [lib] The file set describing the library file.
    # [link] The file set describing the link file.
    # [include] The file set describing the include files.
    def initialize(paramBag)
      @Id = paramBag[:id] || ""
      @Os = paramBag[:os] || ""
      @Architecture = paramBag[:arch] || ""
      @Configuration = paramBag[:conf] || ""
      
      @LibraryFileSet = paramBag[:lib] || FileSet.new()
      @LinkFileSet = paramBag[:link] || FileSet.new()
      @IncludeFileSet = paramBag[:include] || FileSet.new()
    end   
    
    def initialize_copy(original)
      @Id = Clone(original.Id)
      
      @Os = Clone(original.Os)
      @Architecture = Clone(original.Architecture)
      @Configuration = Clone(original.Configuration)
      
      @LibraryFileSet = Clone(original.LibraryFileSet)
      @LinkFileSet = Clone(original.LinkFileSet)
      @IncludeFileSet = Clone(original.IncludeFileSet)
    end
    
    # Fill the file sets that will contain the library and include files.
    def Fill
      if(@filled)
        return
      end
      
      @LibraryFileSet.Fill()
      @LinkFileSet.Fill()
      @IncludeFileSet.Fill()
      
      @filled = true
    end
  end
  
end