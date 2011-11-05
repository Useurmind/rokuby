module RakeBuilder
  # Represents a windows dll.
  class WindowsDll < LibraryBase
    # [name] The name of the library.
    # [libraryPath] The path where the library is located.
    # [headerPaths] An array with the paths to the header files of the library.
    # [copyFileName] The name of the file that should be copied to the release directory.
    def initialize(paramBag)
      paramBag[:name] = (paramBag[:name] or nil)
      paramBag[:libraryPath] = (paramBag[:libraryPath] or nil)
      paramBag[:headerPaths] = (paramBag[:headerPaths] or [])
      paramBag[:copyFileName] = (paramBag[:copyFileName] or nil)
      paramBag[:headerNames] = (paramBag[:headerNames] or [])
      
      if(paramBag[:name])
        fileName = "#{paramBag[:name]}.dll"
      else
        fileName = nil
      end
      
      super(paramBag[:name], fileName, paramBag[:libraryPath], paramBag[:headerPaths], paramBag[:headerNames])
    end
  end
end
