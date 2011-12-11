module RakeBuilder
  # This type of processor finds a set of files on the system based on predefined values.
  # Allowed inputs are FileSpecification information units.
  # The outputs of this processor are one FileSet information unit for each input.
  class FileFinder < Processor
    include DirectoryUtility
    
    def initialize(name)
      super(name)
      
      @knownInputClasses.push(RakeBuilder::FileSpecification)
    end
    
    def _ProcessInputs      
      @inputs.each() do |fileSpec|
        fileSet = FileSet.new()
        fileSet.GetDefines(fileSpec)
          
        fileSet.FilePaths = FindFilesInDirectories(fileSpec.IncludePatterns, fileSpec.ExcludePatterns, fileSpec.SearchPaths)
        fileSet.FileDirectories = []
        fileSet.RootDirectories = Clone(fileSpec.SearchPaths())
        
        fileSet.FilePaths.each do |path|
          fileDir = path.DirectoryPath()
          if(fileSet.FileDirectories.include?(fileDir))
            next
          end
          
          fileSet.FileDirectories.push(fileDir)
        end
        
        @outputs.push(fileSet)
      end
    end
  end
end
