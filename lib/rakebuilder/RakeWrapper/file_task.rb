module Rake
  # Overwrite some of the functionality in the file task defined by rake.
  class FileTask
    include RakeBuilder::PathUtility
    
    # Is this file task needed?  Yes if it doesn't exist, or if its time stamp
    # is out of date.
    alias needed_old? needed?
    def needed?
      val = nil
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        val = needed_old?
      end
      return val
    end
     
    # Time stamp for file task.
    alias timestamp_old timestamp
    def timestamp
      val = nil
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        val = timestamp_old
      end
      return val
    end
  end
end