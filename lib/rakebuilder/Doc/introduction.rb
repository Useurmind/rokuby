#= Rokuby
#
#== What is Rokuby?
#
#Rokuby is the name of a build tool to create C/C++ project.
#It is based on the rake tool with extensions that incorporate ideas from other
#build tools like CMake to make it easier to create complex projects.
#
#*Features*:
#* Define software projects
#* Build your projects on different platforms
#* Visual Studio Solution Creation
#
#== How does it work?
#
#Rokuby works similar to Rake where you can define tasks that can be made dependent
#on each other.
#But there are also some important differences between Rake and Rokuby:
#Also tasks are a great thing they are missing an important feature: It is not possible
#to easily transport information between tasks that let you easily combine them to create
#complex solutions.
#Therefore, Rokuby implements a new paradigm which is called *Processors*. They are similar
#to tasks in that they are dependent on each other and execute their dependencies before
#executing themselves. On the other hand they are more complex than tasks because they
#are able to transmit information between each other. In that manner they build up <b>Process
#Chains</b> that can be very complex beasts that transport information from their starting point
#to at least one end point (which are processors).
#The information that is transported between the processors comes in so called <b>Information Units</b>.
#They are arbitrary sets of information whose format must be known to the processor so he can
#manage to process these units.
#In this manner the processors can define a set of valid information units that they accept
#and the user can input these units into the processor to let him create something that the user
#needs (like a software project).
#
#Examples for information units:
#* File specifications (specify the location of a set of files)
#* Library specification (specify the location of a software library)
#* Project description (contains meta information about a software project)
#
#Examples of processors:
#* File finder (find a file specified by a file specification)
#* Library finder (find a software library specified by a library specification)
#* Project builder (build a software project)
#
#== Defining a Build Process
#
#Rokuby comes with several premade processors and information units that can be handed to them.
#Defining instances of both is made available trough a build in DSL which resembles the Rake
#DSL. Nevertheless, there are important differences which are necessary to include the new features
#of the build tool.
#
#=== The process of finding files
#
#Finding files is one of the most important tasks of a build system because it is made to process
#files into other files. Therefore, this process must be very flexible.
#Finding files works by specifying the file location in a file specification and handing it to
#a file finder processor which produces a file instance that represents the files that were found.
#Lets see it in a simple example:
#Assume that we have the following directory structure:
#* Current directory: .
#* Searched file: ./src/main.cpp
#
#We can now create a file specification that targets the given file:
#
# fileSpec :SourceFile, {
#   inPats: ["^main\.cpp$"],
#   sPaths: [projPath("src")]
# }
#
#After that the file specification wanders into a file finder to locate the specified files:
# desc "Find the main.cpp file"
# fileFinder :FindSourceFile, :ins => [fileSpec(:SourceFile)] do |fileFinder|
#   fileSet = fileFinder.GetOutputByClass(FileSet)
#  
#   puts "#{[fileSet]}"
# end
#
#When you now save this in a project file ProjectDefinition.rb and execute "rokuby FindSourceFile" in the folder
#where this project definition is located rokuby will try to find the file and print the set of files that
#was found (even if no files were found, in which case the file set will almost empty).
#
#=== Building a more complex Project
#
#
#
#=== Project Files and their Namespaces
#
#==== Project Files
#
#Learn more under {Project Files}[link:lib/rakebuilder/Doc/project_files_rb.html]
#
#Understanding how project files are loaded and processed is important to be able to effectively work with
#Rokuby. Executing "rokuby" in a folder will load and process the first project file that is found in that directory.
#Project files can have any name but only some names are recognized by default. Loading an arbitrary project
#file is possible through the "-f" option.
#
#Also Rokuby allows the user to load other project files by the means of an import, e.g.:
#+import "subpath/ProjectDefinition.rb"+
#
#This will load and process another project file with the given path which is treated as a new project (in contrast
#to the ruby require statement that works as expected).
#
#Simple projects that only contain one project file can be complex to create, but joining two projects with
#different project files is even more challenging. Rokuby supports the inclusion of several project files that
#describe different parts of the whole project (which can also be foreign projects). To assure that now information
#of one project file can disturb the information in another project file, Rokuby will load project files strictly
#sepparated from each other. On the one hand this makes sure that no problems occur through global variables but also
#can make the life of a programmer harder because the information in one project file is strictly separated from
#information in another project file.
#
#==== Addressing Tasks in different Project Files
#
#To overcome this problem Rokuby allows to address tasks, information units and processors through the project files
#path in the directory structure.
#An example:
#Asume the following directory structure
#* Current directory: .
#* Loaded project file: ./ProjectDefinition.rb
#* Imported project file: ./subfolder/ProjectDefinition.rb
#
#If we now want to address an entity in the imported project file from the main project file we can simply do it.
#Making a task +task1+ in the main project file depending on a task +task1+ in the subproject file:
#
# importPath = "subfolder/ProjectDefinition.rb"
#
# import importPath
#
# task :task1 => [importPath + ":task1"]
#
#This will lead to the execution of +task1+ in the imported project file before the +task1+ in the main project file.
#(This is by the way one of the only differences between tasks in Rokuby and Rake).
#
#=== Project Paths
#
#An important thing when building projects is the management of paths and how they are related to the current work directory.
#Rokubys solution to this problem is that of project paths. These paths do not only hold a simple string that represents a path.
#Instead they save the absolute path as well as the relative part of the path that is defined. This works as follows:
#* Each project file is parsed and executed in the directory it is saved in.
#* Project paths always extract information regarding the current directory and combine it with the relative path the user inserts.
#* The complete information makes it possible to extract a relative path even if you are in the context of another project file.
#These abilities make it very easy to handle paths because every paths knows where it belongs to.
#The only drawback for the user is that it is necessary for him to define project paths instead of normal strings.
#To ease this task Rokuby provides a shortcut for defining a project path:
# 
# # Define a project path that is relative to the current directory
# projPath("relative/path/to/my/file.txt")
# 
# # Define a project path that is relative to a base directory
# projPath({base: "base/path", relative: "relative/path/to/my/file.txt"})
#
#=== Information Units
#
#Information units are the elements in Rokuby that carry all information that is used in the process of creating a
#project. They are simple and relatively stupid objecs that can only be used to carry and structure information (nothing more!).
#Defining an information unit is easy as you have already seen in the file set example above. Generally the definition
#of an information unit has the following format:
#
# # Define an information unit with name :IUName and some given attributes
# infoUnit IUClass, :IUName, :attr1 => valu1,
#                            :attr2 => value2 #...
#
#Notice that you can define any class of information unit with this syntax. You just need to define a class that can carry data
#and is derived from a proper information unit base class.
#There are also a lot of abbreviations for several information unit classes, e.g. +fileSpec+ for file specifications.
#Notice that information units that are created with a name are saved in the project file and can be addressed later on with their
#class,name combination. For example:
#
# # define information unit
# fileSpec :SourceCode, :inPats => [...], :sPaths => []
# 
# # use information unit in source code specification
# srcSpec :SourceCode, :srcSpec => fileSpec(:SourceCode),
#                      :inclSpec => fileSpec(:Includes),
#                      :defs => ["USE_SOURCE_CODE"]
#
#Notice that almost every information unit should be able to carry defines that are specific to this information unit and are only
#applied when this information unit is involved.
#The ability to define and reuse information units and the capabilities of project paths make it possible to use information units
#independently of the project file where they were defined. You can even address information units from outside the project file the
#same way you would do with tasks and processors.
#
#=== Processors and Process Chains
#
#==== The Ins and Outs of Processors
#
#Processors are entities that are designed to take a set of inputs and produce a set of outputs from the given inputs. The rules of
#defining and connecting processors are similar to the rules of defining and connecting Rake tasks.
#In general the definition of a processor looks like this:
#
# # define a processor
# defineProc ProcClass, :ProcName, :ins => [...],
#                                  :deps => [...],
#                                  ...more attributes...
#
#The +:ins+ attribute is an array of information unit that can be handed to the processor for processing. Additionally, the processor
#can depend on some other processor that are specified over the +:deps+ attribute which is an array of processors. These dependencies
#will be executed before the processor itself is executed and the output that is generated by them is added to the inputs that this
#processor will use during its execution.
#
#====Process Chains
#
#To ease the task of connecting processors (and to generate special purpose chains of processors) there are process chains. One feature
#that process chains provide is the markup to more simply connect a set of processors into chains.
#For example:
#
# #define a general purpose process chain of some known processors
# chain :ChainName, :in, :Proc1Name, :Proc2Name, :Proc3Name, :out
#
#This code defines a process chain that connects two processors with the names Proc1Name, Proc2Name and Proc3Name. The +:in+ and +:out+
#symbols represent two processors that each process chain posseses, namely the input processor and the output processor. These processors
#are simple processors that just forward their input values as their output values. They are needed to implement a feature of a process chain
#that makes them very versatile: process chains are processors. This means that process chains can be used like processors in another process
#chain. They gather input in their input processor and produce output that is placed in their output processor.
#(In fact some of the more complex processors are process chains that simply reuse other processors to implement their functionality)
#
#====Processors and Tasks
#
#Rokuby adopts the tasking features of Rake so that the user does not loose the possibility to use tasks in their scripts. To tightly integrated
#processors into the world of tasks it was decided to implement processors as a new sort of tasks. This makes it possible to make processors depend
#on tasks and the other way round. With this integration it is easy for users to interweave processors and tasks.
#
# #define a task
# task :MyTask do
#   puts "Working in MyTask"
# end
#
# #define a processor
# defineProc ProcClass, :MyProc, :ins => [...]
#
# #make MyTask dependent on MyProc so that MyProc is executed before MyTask
# task :MyTask => [:MyProc]
#
#You could also do it the other way round and make MyProc depend on the task instead
#
# #make MyProc dependent on MyTask so that MyTask is executed before MyProc
# proc :MyProc, :deps => [:MyTask]
#
#