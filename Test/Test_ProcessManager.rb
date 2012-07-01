require File.join(File.dirname(__FILE__), "unit_tests")
require File.join(File.dirname(__FILE__), "task_descriptor")

include Rokuby
include UnitTests

class ProcessManagerTest
  include ProcessManager
  
  def initialize()
    super
  end
  
  # Test if the process manager would correctly parse the given arguments so
  # that the expected arguments are retrieved.
  def TestArgumentParsing(expName, expInputs, expValueMap, expTaskArgs, expTaskDeps, *args)
    puts "Arguments for test are: #{args}"
    puts
    name, args = _GetProcessorName(*args)
            
    inputs, valueMap, taskArgs, taskDeps = _ParseProcessorArgs(*args)
     
    TestEqual(name, expName)
    
    TestEqual(inputs, expInputs)
    
    TestEqual(valueMap, expValueMap)
    
    TestEqual(taskArgs, expTaskArgs)
    
    TestEqual(taskDeps, expTaskDeps)
    puts
  end
end
  
processManagerTest = ProcessManagerTest.new()


desc "Execute some tests that check the process manager parsing for errors"
task :TestProcessorArguementParsing => [
                          :Test_StringNameOnly,
                          :Test_SymbolNameOnly,
                          :Test_NameAndDeps,
                          :Test_NameAndInputs,
                          :Test_NameInputsValueMap,
                          :Test_NameInputsTaskArgs,
                          :Test_NameInputsTaskArgsAndDeps
                          ] do |task|
  taskDescriptor task
end

task :Test_StringNameOnly do
  puts "Test_StringNameOnly"
    
  processManagerTest.TestArgumentParsing("name", [], {}, [], [], "name")
end

task :Test_SymbolNameOnly do
  puts "Test_SymbolNameOnly"
  
  processManagerTest.TestArgumentParsing(:name, [], {}, [], [], :name)
end

task :Test_NameAndDeps do
  puts "Test_NameAndDeps" 
    
  processManagerTest.TestArgumentParsing(:name, [], {}, [], [:dep1, "dep2"], :name, :procDeps => [:dep1, "dep2"])
end

task :Test_NameAndInputs do
  puts "Test_NameAndInputs"
  
  processManagerTest.TestArgumentParsing(:name, [:inp1, "inp2"], {}, [], [], :name, :procIns => [:inp1, "inp2"])
end

task :Test_NameInputsValueMap do
  puts "Test_NameInputsValueMap"
  
  processManagerTest.TestArgumentParsing(:name, [:inp1, "inp2"], {val1: "val1", val2: :val2}, [], [], :name, :val2 => :val2, :procIns => [:inp1, "inp2"], :val1 => "val1")
end

task :Test_NameInputsTaskArgs do
  puts "Test_NameInputsTaskArgs"
  
  processManagerTest.TestArgumentParsing(:name, [:inp1, "inp2"], {}, ["arg1", :arg2], [], :name, :procIns => [:inp1, "inp2"], :procArgs => ["arg1", :arg2])
end

task :Test_NameInputsTaskArgsAndDeps do
  puts "Test_NameInputsTaskArgsAndDeps"
  
  processManagerTest.TestArgumentParsing(:name, [:inp1, "inp2"], {}, ["arg1", :arg2], [:dep1, "dep2"], :name, :procIns => [:inp1, "inp2"], :procArgs => ["arg1", :arg2], :procDeps => [:dep1, "dep2"])
end

