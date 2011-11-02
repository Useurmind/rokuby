desc "Task to test basic task functionality"
task :TestTask => [:TestInSubfolder, "TestfileBase", "TestfileBase2"] do |task|
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

projectInclude "Test/ProjectDefinition"

clean "TestfileBase"
clean "TestfileBase2"

task :default => :TestTask