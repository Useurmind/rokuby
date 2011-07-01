module RakeBuilder
  # Represents a windows lib.
  # [CopyFileName] The name of the file that should be copied to the release directory.
  #                Should be located in the same directory as the lib file.
  #                This exists because libs can reference a dll or themselves.
  class WindowsLib < LibraryBase
    attr_accessor :CopyFileName
    
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
        fileName = "#{paramBag[:name]}.lib"
      else
        fileName = nil
      end
      
      @CopyFileName = paramBag[:copyFileName]
      #puts "Set dllname to #{@DllName}"
      
      super(paramBag[:name], fileName, paramBag[:libraryPath], paramBag[:headerPaths], paramBag[:headerNames])
    end
    
    def GetFullCopyFilePath
      if(@LibraryPath == nil)
        return nil
      end
      return JoinPaths([ @LibraryPath, @CopyFileName ] )
    end
  end
end
