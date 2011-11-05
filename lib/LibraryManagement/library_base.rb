module RakeBuilder

  # This is a base class for all types of libraries. Don't use it directly!
  # It is important to know the assumptions that are made about each library.
  # - Each library can be located in exactly one folder, which is known.
  #   If the library can be located in different directories determine the correct one pre build.
  # [Name] This is an identifier for the library (e.g. 'bla').
  # [FileName] The name of the file that represents the library. Set by derived classes.
  # [LibraryPath] The path where the library is located.
  # [HeaderPaths] All include paths that are needed to find the headers of this library.
  class LibraryBase
    include GeneralUtility
    include DirectoryUtility

    attr_accessor :Name
    attr_accessor :FileName
    attr_accessor :LibraryPath
    attr_accessor :HeaderPaths
    attr_accessor :HeaderNames

    def initialize(name, fileName, libraryPath, headerPaths, headerNames)
      @Name = name
      @FileName = fileName
      @LibraryPath = libraryPath
      @HeaderPaths = headerPaths
      @HeaderNames = headerNames
    end

    def initialize_copy(original)
      @Name = Clone(original.Name)
      @FileName = Clone(original.FileName)
      @LibraryPath = Clone(original.LibraryPath)
      @HeaderPaths = Clone(original.HeaderPaths)
      @HeaderNames = Clone(original.HeaderNames)
    end
  end
end
