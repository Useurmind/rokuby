module RakeBuilder
  # Represents a static library under linux.
  class StaticLibrary < LibraryBase
    # [name] The name of the library.
    # [libraryPath] The path where the library is located.
    # [headerPaths] An array with the paths to the header files of the library.
    def initialize(paramBag)
      paramBag[:name] = (paramBag[:name] or nil)
      paramBag[:libraryPath] = (paramBag[:libraryPath] or nil)
      paramBag[:headerPaths] = (paramBag[:headerPaths] or [])
      paramBag[:headerNames] = (paramBag[:headerNames] or [])
      
      fileName = "lib#{paramBag[:name]}.a"
      
      super(paramBag[:name], fileName, paramBag[:libraryPath], paramBag[:headerPaths], paramBag[:headerNames])
    end
  end
end
