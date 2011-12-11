module RakeBuilder
  # This class describes how a library instance can be found on a system.
  # [LibraryFileSpec] The file specification for the library file.
  # [LinkFileSpec] The file specification for the file that should be linked against.
  # [IncludeFileSpec] The file specification for the include files of the library.
  class LibraryLocationSpec < InformationUnit
    attr_accessor :LibraryFileSpec
    attr_accessor :LinkFileSpec
    attr_accessor :IncludeFileSpec
    
    def initialize()
      @LibraryFileSpec = FileSpecification.new()
      @LinkFileSpec = FileSpecification.new()
      @IncludeFileSpec = FileSpecification.new()
    end
    
    def initialize_copy(original)
      @LibraryFileSpec = Clone(original.LibraryFileSpec)
      @LinkFileSpec = Clone(original.LinkFileSpec)
      @IncludeFileSpec = Clone(original.IncludeFileSpec)
    end
  end
end
