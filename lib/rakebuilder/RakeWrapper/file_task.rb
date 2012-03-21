module Rake
  # Overwrite some of the functionality in the file task defined by rake.
  class FileTask
    include RakeBuilder::PathUtility
    
    # Is this file task needed?  Yes if it doesn't exist, or if its time stamp
    # is out of date.
    alias needed_old_filetask? needed?
    def needed?
      val = nil
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        val = needed_old_filetask?
      end
      return val
    end
     
    # Time stamp for file task.
    alias timestamp_old_filetask timestamp
    def timestamp
      val = nil
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        val = timestamp_old_filetask
      end
      return val
    end
  end
end
