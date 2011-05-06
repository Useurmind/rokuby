require 'LibraryManagement/library_base'

module RakeBuilder
  # Represents a windows dll.
  class WindowsDll < LibraryBase
    def initialize(name, libraryPath, headerPaths)
      fileName = "lib#{name}.dll"
      super.initialize(name, fileName, libraryPath, headerPaths)
    end
  end
end
