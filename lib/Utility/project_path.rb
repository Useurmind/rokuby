module RakeBuilder
  
  # A representation for a path.
  # The path contains a relative part as well as an absolute path.
  # This allows to save paths that are relative to a given directory and still
  # use them in directories that are not related to the current directory.
  # It also allows to choose between absolute and relative paths at any time.
  # All functions working on the path return a new copy that represents the manipulated path.
  # [BasePath] The base path from where the relative path is used to estimate the absolute path.
  # [RelativePath] The path that is used on top of the base path to estimate the absolute path.
  class ProjectPath
    include PathUtility
    
    attr_accessor :BasePath
    attr_accessor :RelativePath
    
    # Is this path an absolute path
    def absolute?
      absolute = false
      if(@BasePath)
        absolute = PathAbsolute?(@BasePath)
      elsif(@RelativePath)
        absolute = PathAbsolute?(@RelativePath)
      end
      
      return @Absolute || absolute
    end
    
    # Does this path represent an existing file.
    def file?
      return File.file?(AbsolutePath())
    end
    
    # Does this path represent the path to a file (not necessarily existing).
    def filePath?
      isFilePath = false
      endingParts = AbsolutePath().split(".")
      if(!endingParts[endingParts.length-1].match("/") or file?())
        isFilePath = true
      end
      
      return isFilePath
    end
    
    # Does this path represent an existing directory.
    def directory?
      return File.directory?(AbsolutePath())
    end
    
    # Returns a path that represents the path saved in this project path.
    def AbsolutePath      
      return JoinPaths([@BasePath, @RelativePath])
    end
    
    # Return the relative directory path contained in this project path.
    # Removes file name if present.
    def RelativeDirectory
      if(directory?() or !filePath?())
        return @RelativePath
      end
      return JoinPaths(@RelativePath.split("/")[0..-2])      
    end
    
    # Return the absolute directory path contained in this project path.
    # Removes file name if present.
    def AbsoluteDirectory
      if(directory?() or !filePath?())
        return AbsolutePath()
      end
      return JoinPaths(PathParts()[0..-2])      
    end
    
    # Returns the file name contained in this project path or nil.
    def FileName      
      if(filePath?())
        pathParts = PathParts()
        return pathParts[pathParts.length-1]
      end
      return nil
    end
    
    # Return a project path with the directory path contained in this project path.
    def DirectoryPath
      return ProjectPath.new({base: @BasePath, relative: RelativeDirectory()})
    end
    
    def PathParts
      return AbsolutePath().split("/")
    end
    
    # Initialize a path.
    # If only one string is give this is taken as the relative path and the base path is estimated.
    # [base] The base path of this path (estimated from the current directory if not given).
    # [relative] The relative part of the path.
    # [absolute] Is the input path default (normally estimated automatically, for cases where this is not possible).
    def initialize(paramBag)
      super()
      
      if(paramBag.kind_of?(String))
        base = nil
        relative = FormatPath(paramBag)
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
        @BasePath = FormatPath(Dir.pwd)
      end
      @RelativePath = relative
    end
    
    def CreateCopy()
      copy = ProjectPath.new({base: @BasePath, relative: @RelativePath})
      return copy
    end
    
    def initialize_copy(original)
      @BasePath = Clone(original.BasePath)
      @RelativePath = Clone(original.RelativePath)
    end
    
    # Join the relative parts of this paths with the relative parts of some other paths.
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
    def MakeRelativeTo(path)
      if(path == nil)
        return self
      end
      
      #puts "Making path relative, self: " + self.to_s + ", path: " + path.to_s     
      
      originalPathParts = PathParts()
      pathParts = path.PathParts()
      
      #newPath = ProjectPath.new({base: path.AbsolutePath()})
      
      minPartsNumber = [originalPathParts.length, pathParts.length].min
      commonPartsNumber = 0
      
      for i in 0..minPartsNumber-1
        if(originalPathParts[i] != pathParts[i])
          break
        end
        commonPartsNumber += 1
      end
      
      upSwitches = Array.new(pathParts.length - commonPartsNumber, "..")
      
      return ProjectPath.new({
        base: path.AbsolutePath(),
        relative: JoinPaths(upSwitches + originalPathParts[commonPartsNumber..-1])
      })
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
      if(!path)
        return false
      end
      
      return AbsolutePath() == path.AbsolutePath()
    end   
    
    def str
      return to_s()
    end
    
    def to_s
      return (@BasePath || "") + "|" + (@RelativePath || "nil")
    end
    
    # Create a copy of this path where all parts are absolute.
    def MakeAbsolute()
      return ProjectPath.new(AbsolutePath())
    end
  end
end
