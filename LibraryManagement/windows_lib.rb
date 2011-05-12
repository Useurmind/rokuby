require 'LibraryManagement/library_base'

module RakeBuilder
  # Represents a windows lib.
  class WindowsLib < LibraryBase
    def initialize(name, libraryPath, headerPaths, headerNames=[])
      fileName = "#{name}.lib"
      super(name, fileName, libraryPath, headerPaths, headerNames)
    end
  end
end
