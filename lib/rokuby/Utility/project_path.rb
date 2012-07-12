module Rokuby
  
  # A representation for a path.
  # The path contains a relative part as well as an absolute path.
  # This allows to save paths that are relative to a given directory and still
  # use them in directories that are not related to the current directory.
  # It also allows to choose between absolute and relative paths at any time.
  # All functions working on the path return a new copy that represents the manipulated path.
  class ProjectPath
    include PathUtility
    include GeneralUtility
    
    # @return [String] The base path from where the relative path is used to estimate the absolute path.
    attr_accessor :BasePath
    # @return [String] The path that is used on top of the base path to estimate the absolute path.
    attr_accessor :RelativePath
    
    # @return [true,false] Is this path an absolute path
    def absolute?
      absolute = false
      if(@BasePath && !@RelativePath)
        absolute = PathAbsolute?(@BasePath)
      elsif(@RelativePath)
        absolute = PathAbsolute?(@RelativePath)
      end
      
      return @Absolute || absolute
    end
    
    # @return [true, false] Does the file to which this path points exist.
    def exist?
      return File.exist?(AbsolutePath())
    end
    
    # @return [true, false] Does this path represent an existing file.
    def file?
      return File.file?(AbsolutePath())
    end
    
    # @return [true, false] Does this path represent the path to a file (not necessarily existing).
    def filePath?
      isFilePath = false
      endingParts = AbsolutePath().split(".")
      if(!endingParts[endingParts.length-1].match("/") or file?())
        isFilePath = true
      end
      
      return isFilePath
    end
    
    # @return [true, false] Does this path represent an existing directory.
    def directory?
      return File.directory?(AbsolutePath())
    end
    
    # @return [true, false] Is this an empty directory empty
    def EmptyDirectory?
      return directory?() && Dir.entries(AbsolutePath()).length == 2  # only . and .. are entries of the directory
    end
    
    # @return [String] Returns a path that represents the path saved in this project path.
    def AbsolutePath      
      return JoinPaths([@BasePath, @RelativePath])
    end
    
    # @return [String] The relative directory path contained in this project path, removes file name if present. 
    def RelativeDirectory
      if(directory?() or !filePath?())
        return @RelativePath
      end
      
      return _SplitAndJoinParts(@RelativePath, 1)
    end
    
    # @return [String] The absolute directory path contained in this project path, removes file name if present.
    def AbsoluteDirectory
      if(directory?() or !filePath?())
        return AbsolutePath()
      end
      
      return _SplitAndJoinParts(AbsolutePath(), 1)
    end
    
    # @return [String, nil] Returns the extension of the file to which this path points or nil.
    def FileExt
      fileName = FileName()
      if(fileName)
        fileNameParts = fileName.split(".")
        if(fileNameParts.length >= 2)
          return fileNameParts[fileNameParts.length - 1]
        end
      end
      return nil
    end
    
    # @param [true, false] keepExt True if the extension should be kept, else the extension is removed.
    # @return [String] The file name contained in this project path or nil.
    def FileName(keepExt=true)      
      if(filePath?())
        pathParts = PathParts()
        
        fileName = pathParts[pathParts.length-1]
        
        if(!keepExt)
          fileName = fileName.split(".")[0]
        end
        
        return fileName
      end
      return nil
    end
    
    # @return [ProjectPath] The directory path contained in this project path.
    def DirectoryPath
      return ProjectPath.new({base: @BasePath, relative: RelativeDirectory()})
    end
    
    # @return [Array<String>] The parts of the complete project path.
    def PathParts
      return AbsolutePath().split("/")
    end
    
    # @return [Array<String>] The parts of the relative part of the project path.
    def RelativePathParts
      return RelativePath().split("/")
    end
    
    # Initialize a path.
    # If only one string is give this is taken as the relative path and the base path is estimated.
    # @example Initialize path with BasePath being the current working directory and RelativePath being `myDirectory`.
    #   ProjectPath.new("myDirectory")
    # @example Initialize a path with explicit base and relative part.
    #   ProjectPath.new({base: "C:/my/base/path", relative: "the/relative/path/part"})
    # @param [String, Hash] paramBag This can be a simple string for the relative part (automatic base computation),
    #   or a hash with the different parts of the path, or the absolute path. The keys for the hash are defined below.
    # @option paramBag [String] :base The base path of this path (estimated from the current directory if not given).
    # @option paramBag [String] :relative The relative part of the path.
    # @option paramBag [String] :absolute Is the input path default (normally estimated automatically, for cases where this is not possible).
    def initialize(paramBag)
      #puts "Creating path with #{paramBag}"
      super()
      
      if(paramBag.kind_of?(String))
        base = nil
        relative = FormatPath(paramBag)
        @Absolute = false
      else
        relative = FormatPath(paramBag[:relative]) || ""
        base = FormatPath(paramBag[:base]) || nil
        @Absolute = paramBag[:absolute] || false
      end
      
      if(base)
        absolute = PathAbsolute?(base)
      else
        absolute = PathAbsolute?(relative)
      end
      
      @BasePath = base
      if(!base && !absolute)
        #puts "Estimating base path from #{Dir.pwd}"
        @BasePath = FormatPath(Dir.pwd)
      end
      @RelativePath = relative
    end
    
    # Create a copy of this path with the same base and relative part.
    def CreateCopy()
      copy = ProjectPath.new({base: @BasePath, relative: @RelativePath})
      return copy
    end
    
    # Copy constructor which initializes the copy with the same base and relative part.
    def initialize_copy(original)
      @BasePath = Clone(original.BasePath)
      @RelativePath = Clone(original.RelativePath)
    end
    
    # Join the relative parts of this path with the relative parts of some other paths.
    # @param [Array<ProjectPath>, ProjectPath] paths The paths which should be joined with this path.
    # @return [ProjectPath] A new path that contains the joined paths.
    def Join(paths)
      pathsToJoin = [@RelativePath]
      if(paths.respond_to?(:length))
        paths.each do |path|
          pathsToJoin.concat(path.RelativePath)
        end        
      else
        pathsToJoin.push(paths.RelativePath)
      end
      
      copy = CreateCopy()
      copy.RelativePath = JoinPaths(pathsToJoin)
      
      return copy
    end
    
    # Create an array of paths that contain the paths to folders and files under this path.
    # @return [Array<ProjectPath>] An array containing the subpaths of this path.
    def SubPaths()
      #puts "Searching subpaths in #{to_s()}"
      entries = Dir.entries(AbsolutePath())
      subPaths = []
      
      #puts "Found entries #{entries}"
      
      entries.each do |entry|
        if(entry == ".." || entry == ".")
          next
        end
        
        copy = CreateCopy()
        
        #puts "Copy is #{copy}"
        
        copy.RelativePath = JoinPaths([copy.RelativePath, entry])
        subPaths.push(copy)
        
        #puts "Created path #{copy} for entry #{entry}"
      end
      
      return subPaths
    end
    
    # Compute a path from this path that is relative to the given path.
    # @param [ProjectPath] path The path to which this project path should be made relative.
    # @return [ProjectPath] A new project path which is the same as this but relative to the input path.
    def MakeRelativeTo(path)
      if(path == nil)
        return self
      end
      
      #puts "Making path relative, self: " + self.to_s + ", path: " + path.to_s     
      
      originalPathParts = PathParts()
      pathParts = path.PathParts()
      
      #puts "original parts: #{originalPathParts}"
      #puts "input parts: #{pathParts}"
      
      #newPath = ProjectPath.new({base: path.AbsolutePath()})
      
      minPartsNumber = [originalPathParts.length, pathParts.length].min
      commonPartsNumber = 0
      
      for i in 0..minPartsNumber-1
        if(originalPathParts[i] != pathParts[i])
          break
        end
        commonPartsNumber += 1
      end
      
      #puts "Common parts: #{commonPartsNumber}"
      
      # the paths are basically the same, so we return the path "."
      if(commonPartsNumber == originalPathParts.length && commonPartsNumber == pathParts.length)
        return ProjectPath.new({
          base: path.AbsolutePath(),
          relative: "."
        })
      end

      upSwitchesNumber = pathParts.length - commonPartsNumber
      for i in commonPartsNumber-1..pathParts.length-1
        if(pathParts[i] == '.' or pathParts[i] == '..')
          upSwitchesNumber -= 1
        end
      end
      
      upSwitches = Array.new(upSwitchesNumber, "..")
      
      return ProjectPath.new({
        base: path.AbsolutePath(),
        relative: JoinPaths(upSwitches + originalPathParts[commonPartsNumber..-1])
      })
    end
    
    # (see #Join)
    def +(paths)
      return Join(paths)
    end
    
    # Move up in the directory hierarchy one step.
    # @return [ProjectPath] A new path which represents the parent directory of the old path.
    def Up()
      #puts "Going up in path #{self}"
      
      copy = nil
      if(@RelativePath)        
        copy = CreateCopy()
        copy.RelativePath = _SplitAndJoinParts(@RelativePath, 1)
      else
        newPath = _SplitAndJoinParts(AbsolutePath(), 1)
        copy = ProjectPath.new({absolute: newPath})
      end
      
      #puts "parent path is #{copy}"
      return copy
    end
    
    # Is this path equal to another path.
    # Equallity means same class and same absolute path.
    # @param [ProjectPath] path The other project path which should be tested on equality.
    # @return [true, false] True if the paths are equal.
    def ==(path)
      if(!path || path.class != ProjectPath)
        return false
      end
      
      return AbsolutePath() == path.AbsolutePath()
    end   
    
    # (see #to_s)
    def str
      return to_s()
    end
    
    # This stringifyer is for a human readable string with indication of the relative path.
    # Don't use as string version for functions. Use AbsolutePath, RelativePath, BasePath, etc. instead.
    # @example Path with base part "/base/part" and relative part "relative/part" will become.
    #   "/base/part|relative/part"
    # @return [String] A human readable string representation of the absolute path.
    def to_s
      return (@BasePath || "") + "|" + (@RelativePath || "nil")
    end
    
    # Create a copy of this path where all parts are absolute.
    # @todo Look into this and check.
    # @return [ProjectPath] Project path with only 
    def MakeAbsolute()
      return ProjectPath.new(AbsolutePath())
    end

    private
    
    # Split a path and join a range of parts of it again.
    # @param [String] path The path to split.
    # @param [Fixnum] pop The number of parts that should be popped from the end of the part list.
    # @return [String] The cut path.
    def _SplitAndJoinParts(path, pop)      
      pathParts = path.split("/")[0..-(pop+1)]
      
      result = JoinPaths(pathParts)
      
      # we face an absolute linux part
      if(path.start_with?("/"))
        result = "/" + result
      end
      
      return result
    end
  end
end
