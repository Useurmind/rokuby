module RakeBuilder
  module PathUtility    
    # Joins several parts of a path to one path.
    # Also applies formatting to the paths.
    def JoinPaths(paths)
      formattedPaths = []
      for i in 0..paths.length-1
        formattedPath = FormatPath(paths[i])
        if(formattedPath != nil)
          formattedPaths.push(formattedPath)
        end        
      end
      return RemoveParents(FormatPath(formattedPaths.join("/")) || "")
    end

    # Format the path so that the slashes are correct.
    def FormatPath(path)
      if(!path || path == "")
        return nil
      end
      return path.gsub("\\", "/").gsub("//", "/").gsub("\/.\/", "/").gsub(/^\.\//, "");
    end
    
    def RemoveParents(path)
      pathParts = path.split("/")
      i = 0
      while(pathParts[i] == "..") do
        i+=1
      end
      while (i < pathParts.length) do
        if(i > 0 and pathParts[i] == ".." and pathParts[i-1] != "..")
          pathParts.delete_at(i-1)
          pathParts.delete_at(i-1)
          i-=1
        else
          i+=1
        end
      end
      return (pathParts.join("/") || "")
    end
    
    # Executes the appended block in the given project path.
    def ExecuteInPath(path)
      currentFolder = Dir.pwd
      Dir.chdir(path.AbsolutePath())
      yield if block_given?
      Dir.chdir(currentFolder)
    end
    
    # Is this path an absolute path.
    # Checks for drive letters and beginning slashes.
    def PathAbsolute?(path)
      return path.match("^(([A-Za-z]:)|(\/))") != nil
    end
    
    # Replaces all slashes by backslashes.
    def GetWindowsPath(path)
      return path.gsub("/", "\\")
    end
  end
end
