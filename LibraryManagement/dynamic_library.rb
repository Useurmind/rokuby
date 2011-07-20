module RakeBuilder
  # Represents a dynamic linux library.
  class DynamicLibrary < LibraryBase

    # [name] The name of the library.
    # [libraryPath] The path where the library is located.
    # [headerPaths] An array with the paths to the header files of the library.
    # [version] The version of the library.
    def initialize(paramBag)
      paramBag[:name] = (paramBag[:name] or nil)
      paramBag[:libraryPath] = (paramBag[:libraryPath] or nil)
      paramBag[:headerPaths] = (paramBag[:headerPaths] or [])
      paramBag[:headerNames] = (paramBag[:headerNames] or [])
      paramBag[:version] = (paramBag[:headerNames] or nil)
      
      fileName = "lib#{paramBag[:name]}.so"
      if(paramBag[:version])
        fileName  = fileName + ".#{paramBag[:version]}"
      end

      super(paramBag[:name], fileName, paramBag[:libraryPath], paramBag[:headerPaths], paramBag[:headerNames])
    end
  end
end
