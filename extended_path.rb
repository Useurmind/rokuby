module RakeBuilder
  
  # A representation for a path.
  # All functions working on the path return a new copy that represents the manipulated path.
  # File names in the course of this program should always be relative paths only.
  # [BasePath] The base path from where the relative path is used to estimate the absolute path.
  # [RelativePath] The path that is used on top of the base path to estimate the absolute path.
  class ExtendedPath
    include PathUtility
    
    attr_accessor :BasePath
    attr_accessor :RelativePath
    
    # Is this path an absolute path
    def absolute?
      return @RelativePath == nil
    end
    
    # Does this path represent an existing file.
    def file?
      return File.file?(AbsolutePath())
    end
    
    # Does this path represent the path to a file (not necessarily existing).
    def filePath?
      isFilePath = false
      endingParts = AbsolutePath.split(".")
      if(!endingParts[endingParts.length-1].match("/") or file?())
        isFilePath = true
      end
      
      return isFilePath
    end
    
    # Does this path represent an existing directory.
    def directory?
      return File.directory?(AbsolutePath())
    end
    
    def AbsolutePath
      if(!@RelativePath)
        return @BasePath
      end
      
      return JoinPaths([@BasePath, @RelativePath])
    end
    
    def FileName      
      if(filePath?())
        pathParts = PathParts()
        return pathParts[pathParts.length-1]
      end
      return nil
    end
    
    def DirectoryPath
      if(directory?() or !filePath?())
        return AbsolutePath()
      else
        parts = PathParts()
        parts.delete(parts.length-1)
        return JoinPaths(parts)
      end
    end
    
    def PathParts
      return AbsolutePath().split("/")
    end
    
    # Initialize a path.
    # If only one string is give this is taken as the relative path and the base path is estimated.
    # [base] The base path of this path (estimated from the current directory if not given).
    # [relative] The relative part of the path.
    # [absolute] The absolute path (ignore base and relative path and don't estimate base)(default: nil).
    def initialize(paramBag)
      if(paramBag.kind_of?(String))
        relative = paramBag
        base = nil
        absolute = nil
      else
        relative = paramBag[:relative] or ""
        base = paramBag[:base] or nil
        absolute = paramBag[:absolute] or nil
      end
      
      if(absolute)
        @BasePath = absolute
        @RelativePath = nil
      else
        @BasePath = base or Dir.pwd
        @RelativePath = relative
      end
    end
    
    def CreateCopy()
      copy = ExtendedPath.new({base: @BasePath, path: @RelativePath})
      return copy
    end
    
    def initialize_copy(original)
      @BasePath = Clone(original.BasePath)
      @RelativePath = Clone(original.RelativePath)
    end
    
    # Join the relative parts of this paths with the relative parts of some other paths.
    def Join(paths)
      pathsToJoin = [@RelativePath]
      if(paths.length)
        paths.each do |path|
          pathsToJoin.concat(path.RelativePath)
        end        
      else
        pathsToJoin.append(paths.RelativePath)
      end
      
      copy = CreateCopy()
      copy.RelativePath = JoinPaths(pathsToJoin)
      
      return copy
    end
    
    def SubPaths()
      entries = Dir.entries(directory.AbsolutePath())
      subPaths = []
      entries.each do |entry|
        if(entry == ".." or entry == ".")
          next
        end
        
        copy = CreateCopy()
        copy.RelativePath = JoinPaths([copy.RelativePath, entry])
        subPaths.push(copy)
      end
      
      return subPaths
    end
    
    def +(paths)
      return Join(paths)
    end
    
    # Move up in the directory hierarchy one step.
    def Up()
      parts = PathParts()
      
      if(@RelativePath)
        relativeParts = @RelativePath.split("/")
        relativeParts.delete[relativeParts.length-1]
        copy = CreateCopy()
        copy.RelativePath = JoinPaths(relativeParts)
        return copy
      else
        parts = PathParts()
        parts.delete(parts.length-1)
        copy = ExtendedPath.new({absolute: JoinPaths(parts)})
        return copy
      end
    end
    
    def ==(path)
      return AbsolutePath() == path.AbsolutePath()
    end
  end
end
