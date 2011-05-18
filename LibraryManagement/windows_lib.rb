require 'LibraryManagement/library_base'

module RakeBuilder
  # Represents a windows lib.
  # [DllName] The name of the dll that is referenced by the lib file.
  #           Should be located in the same directory as the lib file.
  class WindowsLib < LibraryBase
    attr_accessor :DllName
    
    def initialize(name, libraryPath, headerPaths, dllname=nil, headerNames=[])
      fileName = "#{name}.lib"
      if(dllname == nil)
        @DllName = "#{name}.dll"
      else
        @DllName = "#{dllname}.dll"
      end
      puts "Set dllname to #{@DllName}"
      
      super(name, fileName, libraryPath, headerPaths, headerNames)
    end
    
    def GetFullDllPath
      if(@LibraryPath == nil)
        return nil
      end
      return JoinPaths([ @LibraryPath, @DllName ] )
    end
  end
end
