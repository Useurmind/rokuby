= Rokuby

== What is Rokuby?

Rokuby is the name of a build tool to create C/C++ project.
It is based on the rake tool with extensions that incorporate ideas from other
build tools like CMake to make it easier to create complex projects.

*Features*:
[Define software projects]
[Build your projects on different platforms]
[Visual Studio Solution Creation]

== How does it work?

Rokuby works similar to Rake where you can define tasks that can be made dependent
on each other.
But there are also some important differences between Rake and Rokuby:
Also tasks are a great thing they are missing an important feature: It is not possible
to easily transport information between tasks that let you easily combine them to create
complex solutions.
Therefore, Rokuby implements a new paradigm which is called *Processors*. They are similar
to tasks in that they are dependent on each other and execute their dependencies before
executing themselves. On the other hand they are more complex than tasks because they
are able to transmit information between each other. In that manner they build up *Process
Chains* that can be very complex beasts that transport information from their starting point
to at least one end point (which are processors).
The information that is transported between the processors comes in so called *Information Units*.
They are arbitrary sets of information whose format must be known to the processor so he can
manage to process these units.
In this manner the processors can define a set of valid information units that they accept
and the user can input these units into the processor to let him create something that the user
needs (like a software project).

Examples for information units:
* File specifications (specify the location of a set of files)
* Library specification (specify the location of a software library)
* Project description (contains meta information about a software project)

Examples of processors:
* File finder (find a file specified by a file specification)
* Library finder (find a software library specified by a library specification)
* Project builder (build a software project)

== Defining a Build Process

Rokuby comes with several premade processors and information units that can be handed to them.
Defining instances of both is made available trough a build in DSL which resembles the Rake
DSL. Nevertheless, there are important differences which are necessary to include the new features
of the build tool.

=== The process of finding files

Finding files is one of the most important tasks of a build system because it is made to process
files into other files. Therefore, this process must be very flexible.
Finding files works by specifying the file location in a file specification and handing it to
a file finder processor which produces a file instance that represents the files that were found.
Lets see it in a simple example:
Assume that we have the following directory structure:
[Current directory] .
[Searched file] ./src/main.cpp

We can now create a file specification that targets the given file:
+fileSpec :SourceFile, {
  inPats: ["^main\.cpp$"],
  sPaths: [projPath("src")]
}+

After that the file specification wanders into a file finder to locate the specified files:
+desc "Find the main.cpp file"
fileFinder :FindSourceFile, :ins => [fileSpec(:SourceFile)] do |fileFinder|
  fileSet = fileFinder.GetOutputByClass(FileSet)
  
  puts "#{[fileSet]}"
end+

When you now save this uin a file ProjectDefinition.rb and execute "rokuby FindSourceFile" in the folder
where this project definition is located rokuby will try to find the file and print the set of files that
was found (even if no files were found, in which case the file set will almost empty).

=== Building a more complex Project



=== Project Files and Project Paths

