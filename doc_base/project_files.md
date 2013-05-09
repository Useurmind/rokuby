Project Files
=============
Project files are similar to the rakefile/makefile/CMakeList.txt files in the corresponding software systems. In the
project files you write describe your project and the process of building it. 

By processing a project file Rokuby loads the description of the project and build process for that project. Executing a 
build process is then done by choosing a processor/task that leads to the execution of the process.

Understanding how project files are loaded and processed is important to be able to effectively work with
Rokuby. Executing "rokuby" in a folder will load and process the first project file that is found in that directory.
Project files can have any name but only some names are recognized by default. These include:

- ProjectDefinition(.rb)
- projectDefinition(.rb)
- projectdefinition(.rb)

Loading an arbitrary project file is possible through the "-f" option.

	rokuby -f path/to/project/file

Importing Project Files
-----------------------	
Rokuby allows the user to load other project files by the means of an import, e.g.:
 
	import "subpath/ProjectDefinition.rb"

This will load and process another project file and makes the information units, processors and tasks available in the loading
project file.
To assure that no information of one project file can disturb the information in another project file, Rokuby will 
load project files strictly separated from each other. On the one hand this makes sure that no problems occur through 
global variables but also can make the life of a programmer harder because the information in one project file is strictly 
separated from information in another project file.
In contrast, the ruby require statement that works as expected.

The object of the imported project file are then available by prefixing each object name with the complete path to the imported
project file like this:

	"subpath/ProjectDefinition.rb:task1"
	
This naming scheme can also be applied from the command line to execute tasks in imported project files.

This import of project files is very convenient in multi project setups where all projects provide a project file. By importing all
project files of the sub project into the project file that creates the complete solution it is possible to nicely separate the
project description of different projects. Especially when including external projects this is advantageous.



