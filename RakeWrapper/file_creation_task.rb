module Rake

  # Redefine some of the functionality in rake file creation tasks.
  class FileCreationTask
    # Is this file task needed?  Yes if it doesn't exist.
    alias needed_old? needed?
    def needed?
      val = nil
      ExecuteInPath(@ProjectFile.Path().DirectoryPath()) do
        val = needed_old?
      end
      return val
    end
  end

end
