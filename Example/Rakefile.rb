$: << File.expand_path(File.dirname(__FILE__) + "/RakeBuilder")

require "requires"

configuration = CppProjectConfiguration.new()
configuration.Includes = ['stdafx.h']
configuration.Sources = ['main.cpp']
configuration.IncludeDirectories = ['include']
configuration.SourceDirectories = ['src']
configuration.Defines =["-D1"]
#configuration.PrecompiledHeader
#configuration.ProjectDirectory =
#configuration.CompilesDirectory
configuration.BinaryName = "program"
#configuration.BinaryType

compiler = GppCompileOrder.new()
compiler.ProjectConfiguration = configuration
compiler.CompilerOptions = ["compileOption"]
compiler.LinkOptions = ["linkOption"]

compiler.CreateProjectTasks()

desc "Build the project with the g++ compiler"
task :gpp => [compiler.EndTask]

desc "Build the visual studio 2010 project that can be used to compile the project"
task :vs2010 do
	innerTask=CppProjectFileCreator.new()
	innerTask.HeaderFiles = ['stdafx.h']
	innerTask.SourceFiles = ['main.cpp']
	innerTask.PrecompiledHeader = 'stdafx.cpp'
	innerTask.IncludeDirectories = ['include']
	innerTask.SourceDirectories = ['src']
	innerTask.buildProjectFile();

  innerTask2=CppFilterFileCreator .new()
	innerTask2.HeaderFiles = ['stdafx.h', 'include2.h']
	innerTask2.SourceFiles = ['main.cpp']
	innerTask2.PrecompiledHeader = 'stdafx.cpp'
	innerTask2.IncludeDirectories = ['include', 'include/include2']
	innerTask2.SourceDirectories = ['src']
	innerTask2.buildFilterFile();
end

task :default => :gpp

