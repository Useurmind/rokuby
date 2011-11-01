module RakeBuilder
  # This class prints task information on construction.
  class TaskDescriptor
    def initialize(task)
      puts "Executing task #{task.to_s}..."
      puts "Working dir is #{Dir.pwd}"
      puts
    end
  end
end
