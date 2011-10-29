module RakeBuilder
  module PathUtility
    # Joins several parts of a path to one path.
    # Also applies formatting to the paths.
    def JoinPaths(paths)
      formattedPaths = []
      for i in 0..paths.length-1
        formattedPath = FormatPath(paths[i])
        if(formattedPath)
          formattedPaths.push formattedPath
        end        
      end
      return FormatPath(paths.join("/"));
    end

    # Format the path so that the slashes are correct.
    def FormatPath(path)
      if(!path || path == "")
        return nil
      end
      return path.gsub("\\", "/").gsub("//", "/");
    end
    
    # Executes the appended block in the given project path.
    def ExecuteInPath(path)
      currentFolder = Dir.pwd
      Dir.chdir(path.AbsolutePath())
      yield if block_given?
      Dir.chdir(currentFolder)
    end
  end
end