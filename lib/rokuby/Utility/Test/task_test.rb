module Rokuby
  # This class prints task information on construction.
  class TaskTest
    include UnitTests
    
    # Initialize the task descriptor to perform some unit tests.
    # @param [Task] task The task that should be checked.
    # @param [String, Symbol] The exspected name of the task.
    # @param [ProjectPath] workingDirPath The exspected working directory.
    # @param [ProjectPath] projectFilePath The exspected project file of the task.
    def initialize(task, taskName, workingDirPath, projectFilePath)
      puts "Testing task #{task.to_s}..."
      TestEqual(task.name().to_s, taskName.to_s)
      TestEqual(Dir.pwd, workingDirPath.AbsolutePath())
      TestEqual(task.ProjectFile.Path(), projectFilePath)
      puts
    end
  end
end
