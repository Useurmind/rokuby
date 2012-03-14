module RakeBuilder

  module DirectoryUtility
    # Find all files matching a pattern in some directories.
    # Searches recursively. Patterns are applied on the relative paths.
    # [includePatterns] Some RegExps describing the file names.
    # [excludePatterns] Some RegExps that can be used to exclude file names.
    # [directories] The project paths to the directories that should be searched.
    def FindFilesInDirectories(includePatterns, excludePatterns, directories)
      files = []

      #puts "Searching files, current directory is #{Dir.pwd}"

      directories.each { |dir|
        files = files + FindFilesInDirectory(includePatterns, excludePatterns, dir)
      }

      return files
    end

    # Find all files matching a pattern in some directories.
    # Searches recursively. Patterns are applied on the relative paths.
    # [includePatterns] Some RegExps describing the file names.
    # [excludePatterns] Some RegExps that can be used to exclude file names.
    # [directory] The proeject path to the directory that should be searched.
    def FindFilesInDirectory(includePatterns, excludePatterns, directory)
      files = []      
      #puts "Searching files in '#{directory}', found entries: #{entries}"
      
      directory.SubPaths().each do |subPath|

        if(subPath.directory?())
          files = files + FindFilesInDirectory(includePatterns, excludePatterns, subPath)
        else
          entryIsExcluded = false

	  testPath = subPath.RelativePath()

          excludePatterns.each do |pattern|
            if(testPath.match(pattern) != nil)
	      #puts "Excluding file '#{entryPath}' based on pattern '#{pattern}'"
              entryIsExcluded = true
              break
            end
          end

          if(entryIsExcluded)
            next
          end

          entryMatches = false

	  #puts "Checking entry #{entry} for inclusion"
          includePatterns.each do |pattern|
	    #puts "Trying pattern #{pattern}"
            if(testPath.match(pattern) != nil)
	      #puts "Including file '#{entryPath}' based on pattern '#{pattern}'"
              entryMatches = true
              break
            end
          end

          if(entryMatches)
            files = files + [subPath]
          end
        end
      end

      return files
    end

    # Find a file in the given directory.
    # Continues the search in child directories if the file is not found.
    # Returns the first occurence of the file or nil.
    # filename and directory are project paths.
    def FindFileInDirectory(filename, directory)
      filePath = directory.Join(filename)
      if( filePath.file?())
        return filePath
      else
	directory.SubPaths.each do |subPath|
	  fileFound = FindFileInDirectory(filename, subPath)
          if(fileFound != nil)
            return fileFound
          end
	end
        return nil;
      end
    end

    # Find a file in several directories.
    # Also searches in the subdirectories and returns the first occurence found.
    # Throws exception if no file with the name is found.
    def FindFileInDirectories(filename, directories)
      directories.each do |dir|                         
        fileFound = FindFileInDirectory(filename, dir)
        if(fileFound != nil)
          return fileFound
        end
      end
      abort "Could not find file #{filename} in the directories #{directories}"
    end

    # Returns the project pathes to all subdirs of a directory and the directory itself.
    # For example:
    # - dir1
    #   - dir2
    #   - dir3
    #     -dir4
    # => ['dir1', 'dir1/dir2', 'dir1/dir3', 'dir1/dir3/dir4']
    def GetDirectoryTree(baseDirectory, excludePatterns=[], excludeEmpty=false)
      subdirs = [baseDirectory]
      baseDirectory.SubPaths().each do |subPath|
	pathExcluded = false

        excludePatterns.each do |pattern|
          if(subPath.RelativePath.match(pattern) != nil)
            pathExcluded = true
            break
          end
        end

        if(pathExcluded)
          #puts "Excluding path #{subdirPath}"
          next
        end

        if(subPath.directory?())
	  subTree = GetDirectoryTree(subPath, excludePatterns)
	  if(subTree.length > 1 or !excludeEmpty)
	    subdirs = subdirs + subTree
	  end          
        end
      end
      return subdirs
    end
    
    # This creates a ProjectPath that can start with VS variable and nontheless will
    # work properly.
    def GenerateVSVariablePath(path)
      ProjectPath.new({base: path, absolute: true})
    end
  end

end