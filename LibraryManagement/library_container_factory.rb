require "LibraryManagement/library_container"
require "LibraryManagement/dynamic_library"
require "LibraryManagement/static_library"
require "LibraryManagement/windows_dll"

require "directory_utility"
require "general_utility"

module RakeBuilder
  class LibraryContainerFactory
    include DirectoryUtility
    include GeneralUtility

    def initialize
      
    end

    # A fully conventional library conforms to the following properties:
    # - Naming is consistent like this, e.g. for a library called foo the library
    #   binaries are called libfoo.dll, libfoo.so, libfoo.a
    # - Folder structure is consistent like this:
    #     - dll path: basedir/build/windows
    #     - static path: basedir/build/static
    #     - dynamic path: basedir/build/dynamic
    #     - header path: basedir/include
    # Parameters are:
    # [name] The name of the libary.
    # [headerNames] A list with all headers that are relevant for the library.
    # [basedir] The base directory of the library.
    # [static] Should under linux a static library be used.
    def CreateFullyConventionalLibraryContainer(name, headerNames, basedir, static=false)
      libContainer = LibraryContainer.new()
      headerDirs = [JoinPaths([basedir, "include"])]
      
      libContainer.DllLibrary = WindowsDll.new(name, JoinPaths([basedir, "build", "windows"]), headerDirs, headerNames)

      if(static)
        libContainer.StaticLibrary = StaticLibrary.new(name, JoinPaths([basedir, "build", "static"]), headerDirs, headerNames)
      else
        libContainer.DynamicLibrary = DynamicLibrary.new(name, JoinPaths([basedir, "build", "dynamic"]), headerDirs, headerNames)
      end

      return libContainer
    end

    # Creates library that is only used under linux.
    # Parameters are:
    # [name] The name of the libary.
    # [headerNames] A list with all headers that are relevant for the library.
    # [libraryPath] The directory where the library is located.
    # [headerDirs] The include paths of the library.
    # [static] Should it be a static library.
    def CreateLinuxOnlyLibraryContainer(name, libraryPath, headerNames, headerDirs, static=false)
      libContainer = LibraryContainer.new()
      if(static)
        libContainer.StaticLibrary = StaticLibrary.new(name, libraryPath, headerDirs, headerNames)
      else
        libContainer.DynamicLibrary = DynamicLibrary.new(name, libraryPath, headerDirs, headerNames)
      end
      return libContainer
    end

    # Creates a library that is only used under windows.
    # Parameters are:
    # [name] The name of the libary.
    # [headerNames] A list with all headers that are relevant for the library.
    # [libraryPath] The directory where the library is located.
    # [headerDirs] The include paths of the library.
    def CreateWindowsOnlyLibraryContainer(name, libraryPath, headerNames, headerDirs)
      libContainer = LibraryContainer.new()
      libContainer.DllLibrary = WindowsDll.new(name, libraryPath, headerDirs, headerNames)
      return libContainer
    end

    # Create the library container from an array of library objects.
    def CreateLibraryContainerFromLibraryObjects(libraries)
      libContainer = LibraryContainer.new()
      libraries.each do |lib|
        libraryType = lib.class.name
        if(libraryType.eql? WindowsDll.name)
          libContainer.DllLibrary = lib
        elsif(libraryType.eql? DynamicLibrary.name)
          libContainer.DynamicLibrary = lib
        elsif(libraryType.eql? StaticLibrary.name)
          libContainer.StaticLibrary = lib
        else
          abort "Handed not supported object of class '#{libraryType}' to 'CreateLibraryContainerFromLibraryObjects'"
        end
      end
      return libContainer
    end
  end
end
