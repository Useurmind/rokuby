require 'LibraryManagement/library_base'

module RakeBuilder
  # Represents a windows dll.
  class WindowsDll < LibraryBase
    def initialize(name, libraryPath, headerPaths, headerNames)
      fileName = "lib#{name}.dll"
      super.initialize(name, fileName, libraryPath, headerPaths, headerNames)
    end
  end
end
