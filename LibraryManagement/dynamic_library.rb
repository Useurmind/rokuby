require "LibraryManagement/library_base"

module RakeBuilder
  # Represents a dynamic linux library.
  class DynamicLibrary < LibraryBase
    def initialize(name, libraryPath, headerPaths)
      fileName = "lib#{name}.so"
      super(name, fileName, libraryPath, headerPaths)
    end
  end
end
