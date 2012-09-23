include Rokuby::DSL::Test

expectedWorkingDir = projPath(".")
expectedProjectFile = projPath("ProjectDefinition.rb")


desc "Task to test basic task functionality"
task :TestTask => [:TestInSubfolder, "TestfileBase", "TestfileBase2", "./Test\\Test2/projectDefinition:TestTask"] do |task|
   taskTest task, :TestTask, expectedWorkingDir, expectedProjectFile
end

desc "Call a task in another file via filespace"
task :CalledViaFileSpace => ["Test/ProjectDefinition:CalledViaFileSpace"] do |task|
  taskTest task, :CalledViaFileSpace, expectedWorkingDir, expectedProjectFile
end

file "TestfileBase" do |task|
    File.new("TestfileBase", "w")
    taskTest task, :TestfileBase, expectedWorkingDir, expectedProjectFile
end

file_create "TestfileBase2" do |task|
    File.new("TestfileBase2", "w")
   taskTest task, :TestfileBase2, expectedWorkingDir, expectedProjectFile
end

###############################################
# Multitask

multitask_pres = []
for i in 1..100 do
    taskName = "Multi#{i}"
    task taskName do |task|
        puts "Executing multi task #{task.name}"
    end
    multitask_pres.push(taskName)
end

desc "Execute a multitask for testing purposes"
multitask :TestMultitask => multitask_pres do |task|
    taskTest task, :TestMultitask, expectedWorkingDir, expectedProjectFile
end

################################################
# Rules

rule ".rbx" => [".rb"] do |target|
  puts "Executing rule for file #{target.source} to create #{target.name}"
end

################################################
# Directory

desc "Execute some tasks to create directories"
task :TestDirectories => ["BaseTestDirectory", "SubTestDirectory"] do |task|
  taskTest task, :TestDirectories, expectedWorkingDir, expectedProjectFile
end

directory "BaseTestDirectory"

import "TestTasks/ProjectDefinition"

clean "TestfileBase"
clean "TestfileBase2"
clean "BaseTestDirectory"

task :default => [:TestTask]

import "Test_ProjectPath.rb"
import "Test_ProcessManager.rb"