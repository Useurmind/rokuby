module RakeBuilder

  # This class gathers different types of libraries and eases the access to the attributes of the right type.
  class LibraryContainer
    include DirectoryUtility
    include GeneralUtility

    attr_accessor :DllLibrary
    attr_accessor :LibLibrary 
    attr_accessor :StaticLibrary
    attr_accessor :DynamicLibrary

    def initialize
      @DllLibrary = nil
      @LibLibrary = nil
      @StaticLibrary = nil
      @DynamicLibrary = nil
    end

    def initialize_copy(original)
      @DllLibrary = Clone(original.DllLibrary)
      @LibLibrary = Clone(original.LibLibrary)
      @StaticLibrary = Clone(original.StaticLibrary)
      @DynamicLibrary = Clone(original.DynamicLibrary)
    end

    # Get the name for the library used under this OS.
    def GetName(os)
      lib = GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.Name
    end

    # Get the name of the file that should be linked under this OS.
    def GetLinkFileName(os)
      lib = GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.FileName
    end
    
    # Get the name of the file that should be copied into the build directory under this OS.
    def GetCopyFileName(os)
      lib = GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end
      
      if(lib.class.name.eql? WindowsLib.name)
	return lib.CopyFileName
      else
	return lib.FileName
      end
    end

    # Get the path where the library can be found under this OS.
    def GetLibraryPath(os)
      lib = GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.LibraryPath
    end
    
    # Get the full filepath of the library file that should be linked for this OS.
    def GetFullLinkFilePath(os)
      if(GetLibraryPath(os) == nil)
        return nil
      end
      
      return JoinPaths([GetLibraryPath(os), GetLinkFileName(os)]);
    end

    # Get the full filepath of the library file that should be copied into the build directory for this OS.
    def GetFullCopyFilePath(os)
      if(GetLibraryPath(os) == nil or GetCopyFileName(os) == nil)
        return nil
      end
      
      return JoinPaths([GetLibraryPath(os), GetCopyFileName(os)]);
    end

    # Get the paths where headers of the library can be found under this OS.
    def GetHeaderPaths(os)
      lib = GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.HeaderPaths
    end
    
    # Get the names of the header files
    def GetHeaderNames(os)
      lib = GetLibraryForOs(os)
      if(lib == nil)
        return nil
      end

      return lib.HeaderNames
    end
    
    # Get the full names (including path) of the header files
    def GetFullHeaderNames(os)
      lib = GetLibraryForOs(os)
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
      return (@DllLibrary != nil or @LibLibrary != nil)
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

    def GetLibraryForOs(os)
      if(os == :Linux)
        if(@DynamicLibrary != nil)
          return @DynamicLibrary
        else
          return @StaticLibrary
        end
      elsif(os == :Windows)
	if(@DllLibrary != nil)
	  return @DllLibrary
	else
	  return @LibLibrary
	end
      end

      abort "Operating system not supported";
    end
  end
end
