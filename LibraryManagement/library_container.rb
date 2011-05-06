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
      @DynamicLibary = nil
    end

    def initialize_copy(original)
      @DllLibrary = Clone(original.DllLibrary)
      @StaticLibrary = Clone(original.StaticLibrary)
      @DynamicLibary = Clone(original.DynamicLibrary)
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
        puts "Nothing found for lib"
        return nil
      end

      puts "Returning #{lib.HeaderPaths}"
      return lib.HeaderPaths
    end

    # Is this library used under windows
    def UsedInWindows()
      return (@DllLibrary != nil)
    end

    # Is this library used under linux
    def UsedInLinux()
      return (@DynamicLibary != nil or @StaticLibrary != nil)
    end

    # Is this library used as a static library
    def IsStatic()
      return (@DynamicLibary == nil and @StaticLibrary != nil)
    end

    def _GetLibraryForOs(os)
      if(os == :Linux)
        if(@DynamicLibrary != nil)
          return @DynamicLibary
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
