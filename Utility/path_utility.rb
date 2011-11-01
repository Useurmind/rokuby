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
      return FormatPath(formattedPaths.join("/")) || "";
    end

    # Format the path so that the slashes are correct.
    def FormatPath(path)
      if(!path || path == "")
        return nil
      end
      return path.gsub("\\", "/").gsub("//", "/").gsub(".\/", "");
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
  end
end
