module RakeBuilder
  module ProcessorUtility
    def CreateTaskClass(taskClass, *args, &block)
      return ProjectFile().define_task(taskClass, *args, &block)
    end

    def CreateTask(*args, &block)
      return CreateTaskClass(Rake::Task, *args, &block)
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

      task = nil
      if(dependencies)
        task = CreateTaskClass Rake::FileTask, filePath => dependencies
      end

      if(command)
        task = CreateTaskClass Rake::FileTask, filePath do
          SystemWithFail(command, error)
        end
      end
      return task
    end
  end
end