module RakeBuilder
  # Represents a dynamic linux library.
  class DynamicLibrary < LibraryBase
    def initialize(name, libraryPath, headerPaths, headerNames=[])
      fileName = "lib#{name}.so"
      super(name, fileName, libraryPath, headerPaths, headerNames)
    end
  end
end
