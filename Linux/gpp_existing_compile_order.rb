module RakeBuilder
  # This class represents an existing compile order in a subfolder(subproject) of the current project.
  # With this class it is possible to include subprojects that also use the RakeBuilder into a higher
  # level project that needs to compile these subprojects.
  # What it does is essentially to prepend the subfolder where the project is located in front of pathes
  # where this is necessary.
  # It offers a similar interface as GppCompileOrder.
  class GppExistingCompileOrder < GppCompileOrder
    include GeneralUtility
    
    attr_accessor :OriginalCompileOrder
    attr_accessor :Folder
    
    # [compilerOrder] The existing GppCompileOrder.
    # [folder] The folder where the compile order is normally executed.
    def initialize(paramBag)
      @OriginalCompileOrder = paramBag[:compileOrder]
      @Folder = paramBag[:folder]

      SyncToOriginal()
    end

    def SyncToOriginal
      InitCopy(@OriginalCompileOrder)
      @ProjectConfiguration = CppExistingProjectConfiguration.new({
        projectConfiguration: @ProjectConfiguration,
        folder: @Folder
      })
      @Name = "Subproject_#{@ProjectConfiguration.ProjectName}_#{@Name}"
    end

    # Create a file task.
    # [filePath] The path of the file that should be created.
    # [dependencies] Task on which the task depends.
    # [command] The command to execute in the task block.
    # [error] The error message if the command fails.
    # Additionally, one block is given that is essentially the block for the task.
    def CreateFileTask(paramBag)
      filePath = paramBag[:filePath]
      dependencies = paramBag[:dependencies]
      command = paramBag[:command]
      error = paramBag[:error] or ""

      if(!filePath)
        abort "No file path given for file task creation"
      end

      filePath = JoinPaths([ @Folder, filePath ])
      for i in 1..dependencies.length-1
        dependencies[i] = JoinPaths([ @Folder, dependencies[i] ])
      end
      
      if(dependencies)
        file filePath => dependencies
      end

      if(command)
        file filePath do
          ExecuteInFolder(@Folder) do
            SystemWithFail(command, error)
          end
        end
      end
    end
  end
end