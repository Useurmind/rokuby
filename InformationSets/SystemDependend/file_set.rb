module RakeBuilder
  # Information about a set of files
  # Input Values:
  # [IncludePatterns] An array of regex patterns used to define file paths that belong to this file set.
  # [ExcludePatterns] An array of regex patterns used to define file paths that do NOT belong to this file set.
  # [SearchPaths] An array of extended paths representing the search location for the files (searches recursively).
  # Output Values:
  # [FilePaths] An array of file paths that were found based on the patterns and paths defined above.
  # [FileDirectories] An array of directories that were searched (all recursively searched directories).
  class FileSet < SystemInformationSet
    include DirectoryUtility
    
    attr_accessor :IncludePatterns
    attr_accessor :ExcludePatterns
    attr_accessor :SearchPaths
    
    attr_accessor :FilePaths
    attr_accessor :FileDirectories
    
    def initialize
      @IncludePatterns = []
      @ExcludePatterns = []
      @SearchPaths = []
      
      @FilePaths = []
      @FileDirectories = []
      @filled = false
    end
    
    def initialize_copy(original)
      @IncludePatterns = Clone(original.IncludePatterns)
      @ExcludePatterns = Clone(original.ExcludePatterns)
      @SearchPaths = Clone(original.SearchPaths)
      
      @FilePaths = Clone(original.FilePaths)
      @FileDirectories = Clone(original.FileDirectories)
      @filled = original.filled
    end
    
    # Fill the file set with paths that make up the file set.
    def Fill
      if(@filled)
        return
      end
      
      @FilePaths = FindFilesInDirectories(@IncludePatterns, @ExcludePatterns, @SearchPaths)
      @FileDirectories = []
      
      @FilePaths.each do |path|
        fileDir = path.Up()
        if(@FileDirectories.include?(fileDir))
          next
        end
        
        @FileDirectories.push(fileDir)
      end
      
      @filled = true
    end
  end
end