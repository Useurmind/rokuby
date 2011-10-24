module RakeBuilder
  module PathUtility
    # Joins several parts of a path to one path.
    # Also applies formatting to the paths.
    def JoinPaths(paths)
      for i in 0..paths.length-1
        paths[i] = FormatPath(paths[i])
      end
      return FormatPath(paths.join("/"));
    end

    # Format the path so that the slashes are correct.
    def FormatPath(path)
      return path.gsub("\\", "/").gsub("//", "/");
    end
  end
end
