module RakeBuilder

  module DirectoryUtility
    # Find all files matching a pattern in some directories.
    # Searches recursively.
    # [includePatterns] Some RegExps describing the file names.
    # [excludePatterns] Some RegExps that can be used to exclude file names.
    # [directories] The paths to the directories that should be searched.
    def FindFilesInDirectories(includePatterns, excludePatterns, directories)
      files = []

      directories.each { |dir|
        files = files + FindFilesInDirectory(includePatterns, excludePatterns, dir)
      }

      return files
    end

    # Find all files matching a pattern in some directories.
    # Searches recursively.
    # [includePatterns] Some RegExps describing the file names.
    # [excludePatterns] Some RegExps that can be used to exclude file names.
    # [directory] The path to the directory that should be searched.
    def FindFilesInDirectory(includePatterns, excludePatterns, directory)
      files = []

      entries = Dir.entries(directory)
      entries.each { |entry|
        entryPath = JoinPaths([directory,entry])

        if(entry == "." or entry == "..")
          next
        end

        if(File.directory?(entryPath))
          files = files + FindFilesInDirectory(includePatterns, excludePatterns, entryPath)
        else
          entryIsExcluded = false

          excludePatterns.each { |pattern|
            if(entryPath.match(pattern) != nil)
              entryIsExcluded = true
              break
            end
          }

          if(entryIsExcluded)
            next
          end

          entryMatches = false

          includePatterns.each { |pattern|
            if(entryPath.match(pattern) != nil)
              entryMatches = true
              break
            end
          }

          if(entryMatches)
            files = files + [entryPath]
          end
        end
      }

      return files
    end

    # Find a file in the given directory.
    # Continues the search in child directories if the file is not found.
    # Returns the first occurence of the file or nil.
    def FindFileInDirectory(filename, directory)
      if(Dir.entries(directory).include?(filename))
        return "#{directory}/#{filename}"
      else
        Dir.entries(directory).each { |subdir|
          fileFound = FindFileInDirectory(filename, "#{directory}/#{subdir}")
          if(fileFound != nil)
            return fileFound
          end
        }
        return nil;
      end
    end

    # Find a file in several directories.
    # Also searches in the subdirectories and returns the first occurence found.
    # Throws exception if no file with the name is found.
    def FindFileInDirectories(filename, directories)
      directories.each { |dir|
        fileFound = FindFileInDirectory(filename, dir)
        if(fileFound != nil)
          return fileFound
        end
        throw "Could not find file #{filename} in the directories #{directories}"
      }
    end

    # Returns the paths for the directories extended with the base directory path.
    def ExtendDirectoryPaths(baseDirectory, directories)
      extendedDirectories = []

      directories.each { |dir|
        extendedDirectories.push(JoinPaths([baseDirectory, dir]))
      }

      return extendedDirectories
    end

    # Returns the relative pathes to all subdirs of a directory and the directory itself.
    # For example:
    # - dir1
    #   - dir2
    #   - dir3
    #     -dir4
    # => ['dir1', 'dir1/dir2', 'dir1/dir3', 'dir1/dir3/dir4']
    def GetDirectoryTree(baseDirectory, excludePatterns=[])
      subdirs = [baseDirectory]
      Dir.entries(baseDirectory).each { |entry|
        if(entry == "." || entry == "..")
          next
        end

        subdirPath = JoinPaths([baseDirectory, entry])

        pathExcluded = false

        excludePatterns.each{ |pattern|
          if(subdirPath.match(pattern) != nil)
            pathExcluded = true
            break
          end
        }

        if(pathExcluded)
          puts "Excluding path #{subdirPath}"
          next
        end

        if(File.directory?(subdirPath))
          subdirs = subdirs + GetDirectoryTree(subdirPath, excludePatterns)
        end
      }
      return subdirs
    end

    # Joins several parts of a path to one path.
    # Also applies formatting to the paths.
    def JoinPaths(paths)
      for i in 0..paths.length-1
        paths[i] = FormatPath(paths[i])
      end
      return paths.join("/");
    end

    # Format the path so that the slashes are correct.
    def FormatPath(path)
      path.gsub("\\", "/");
    end
  end

end