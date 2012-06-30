module Rokuby
  # A set of files that is present on this system.
  # [FilePaths] An array of project paths for files that were found based on the patterns and paths defined above.
  # [FileDirectories] An array of project paths for the directories that include the files.
  # [RootDirectories] An array of project paths for the topmost directories that include the files.
  class FileSet < InformationInstance
    
    attr_accessor :FilePaths
    attr_accessor :FileDirectories
    attr_accessor :RootDirectories
    
    # The name of the first file in the set.
    def FileName
      if(!FilePath)
        return nil
      end
      return FilePath.FileName
    end
    
    # The path to the first file in the set.
    def FilePath
      if(FilePaths.length == 0)
        return nil
      end
      return FilePaths[0]
    end
    
    def initialize(valueMap=nil)
      @FilePaths = []
      @FileDirectories = []
      @RootDirectories = []
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @FilePaths = Clone(original.FilePaths)
      @FileDirectories = Clone(original.FileDirectories)
      @RootDirectories = Clone(original.RootDirectories)
    end
    
    # Gather the defines from this information unit and all subunits.
    def GatherDefines()
      return @Defines
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      filePaths = valueMap[:FilePaths] || valueMap[:filePaths]
      if(filePaths)
        @FilePaths.concat(filePaths)
      end
      
      fileDirectories = valueMap[:FileDirectories] || valueMap[:fileDirs]
      if(fileDirectories)
        @FileDirectories.concat(fileDirectories)
      end
      
      rootDirectories = valueMap[:RootDirectories] || valueMap[:rootDirs]
      if(rootDirectories)
        @RootDirectories.concat(rootDirectories)
      end
    end
    
    # Join two fileset to one new fileset.
    def +(other)
      if(other == nil)
        return Clone(self)
      end
      
      fileSet = FileSet.new()
      
      fileSet.FilePaths = (self.FilePaths + other.FilePaths).uniq()
      fileSet.FileDirectories = (self.FileDirectories + other.FileDirectories).uniq()
      fileSet.RootDirectories = (self.RootDirectories + other.RootDirectories).uniq()
      fileSet.Defines = (self.Defines + other.Defines).uniq()
      
      return fileSet
    end
    
    #def to_s
    #  val = ""
    #  val += "Files: #{@FilePaths}\n"
    #  val += "File Directories: #{@FileDirectories}\n"
    #end
  end
end
