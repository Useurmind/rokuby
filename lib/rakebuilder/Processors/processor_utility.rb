module RakeBuilder
  # This utility is for processors that need to define tasks and execute them during
  # their execution phase.
  # Creation of tasks in such cases is restricted to the current project file as
  # the execution phase is entered after the task to execute has been chosen.
  # Additionally, the task can only be executed on the fly by program components
  # that know them.
  # For tasks that should be executable by the user, you must define them in the
  # declaration phas, e.g. in _OnAddInput or initialize.
  # With this task can be created with the appropriate functions, you can build chains
  # and in the end append them to the backtask to execute them.
  module ProcessorUtility
    def initialize(*args)
      super(*args)
      
      @BackTask = Rake::Task.define_task "#{@Name}_BackTask"   # used to create a new task chain
    end
    
    def _ExecuteBackTask()
      @BackTask.invoke()
    end
    
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