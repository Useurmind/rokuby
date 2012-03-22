module RakeBuilder
  module ProcessorUtility
    def CreateTaskClass(taskClass, *args, &block)
      ProjectFile().define_task(taskClass, *args, &block)
    end

    def CreateTask(*args, &block)
      CreateTaskClass(Rake::Task, *args, &block)
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

      if(dependencies)
        CreateTaskClass Rake::FileTask, filePath => dependencies
      end

      if(command)
        CreateTaskClass Rake::FileTask, filePath do
          SystemWithFail(command, error)
        end
      end
    end
  end
end