require 'LibraryManagement/library_base'

module RakeBuilder
  # Represents a static library under linux.
  class StaticLibrary < LibraryBase
    def initialize(name, libraryPath, headerPaths, headerNames=[])
      fileName = "lib#{name}.a"
      super(name, fileName, libraryPath, headerPaths, headerNames)
    end
  end
end
