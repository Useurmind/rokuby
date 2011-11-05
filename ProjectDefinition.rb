require File.join(File.dirname(__FILE__), "Test/task_descriptor")
require File.join(File.dirname(__FILE__), "Test/unit_tests")

desc "Task to test basic task functionality"
task :TestTask => [:TestInSubfolder, "TestfileBase", "TestfileBase2", "./Test\\Test2/projectDefinition:TestTask"] do |task|
   taskDescriptor task
end

desc "Call a task in another file via filespace"
task :CalledViaFileSpace => ["Test/ProjectDefinition:CalledViaFileSpace"] do |task|
  taskDescriptor task
end

file "TestfileBase" do |task|
    File.new("TestfileBase", "w")
    taskDescriptor task
end

file_create "TestfileBase2" do |task|
    File.new("TestfileBase2", "w")
   taskDescriptor task
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
    taskDescriptor task
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
  taskDescriptor task
end

directory "BaseTestDirectory"

import "Test/ProjectDefinition"

clean "TestfileBase"
clean "TestfileBase2"
clean "BaseTestDirectory"

task :default => :TestTask

import "Test/Test_ProjectPath.rb"