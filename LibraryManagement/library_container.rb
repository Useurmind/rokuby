require "general_utility"
require "directory_utility"

module RakeBuilder

  # This class gathers different types of libraries and eases the access to the attributes of the right type.
  class LibraryContainer
    include DirectoryUtility
    include GeneralUtility

    attr_accessor :DllLibrary
    attr_accessor :StaticLibrary
    attr_accessor :DynamicLibrary

    def initialize
      @DllLibrary = nil
      @StaticLibrary = nil
      @DynamicLibrary = nil
    end

    def initialize_copy(original)
      @DllLibrary = Clone(original.DllLibrary)
      @StaticLibrary = Clone(original.StaticLibrary)
      @DynamicLibrary = Clone(original.DynamicLibrary)
    end

    # Get the name for the library used under this OS.
    def GetName(os)
      lib = _GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.Name
    end

    # Get the file name of the library used under this OS.
    def GetFileName(os)
      lib = _GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.FileName
    end

    # Get the path where the library can be found under this OS.
    def GetLibraryPath(os)
      lib = _GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.LibraryPath
    end

    # Get the full filepath of the library file for this OS
    def GetFullPath(os)
      if(GetLibraryPath(os) == nil)
        return nil
      end
      
      return JoinPaths([GetLibraryPath(os), GetFileName(os)]);
    end

    # Get the paths where headers of the library can be found under this OS.
    def GetHeaderPaths(os)
      lib = _GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.HeaderPaths
    end
    
    # Get the names of the header files
    def GetHeaderNames(os)
      lib = _GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.HeaderNames
    end
    
    # Get the full names (including path) of the header files
    def GetFullHeaderNames(os)
      lib = _GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      headerPaths = GetHeaderPaths(os)
      fullHeaderNames = []
      lib.HeaderNames.each do |header|
	fullHeaderNames.push(FindFileInDirectories(header, headerPaths))
      end     
      
      return fullHeaderNames
    end

    # Is this library used under windows
    def UsedInWindows()
      return (@DllLibrary != nil)
    end

    # Is this library used under linux
    def UsedInLinux()
      return (@DynamicLibrary != nil or @StaticLibrary != nil)
    end

    # Is this library used as a static library
    def IsStatic()
      return (@DynamicLibrary == nil and @StaticLibrary != nil)
    end
	
	def Equals(other, os)
		return (GetName(os) == other.GetName(os))
	end

    def _GetLibraryForOs(os)
      if(os == :Linux)
        if(@DynamicLibrary != nil)
          return @DynamicLibrary
        else
          return @StaticLibrary
        end
      elsif(os == :Windows)
        return @DllLibrary
      end

      abort "Operating system not supported";
    end
  end
end
