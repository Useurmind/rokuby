# The RakeBuilder tool is a build tool similar to cmake but in the ruby language.
# It should enable the user to easily create build processes for even complicated projects.
#
# RakeBuilder is build upon Rake but modifies it in several ways that changes the current behaviour
# of Rake. These changes are meant to make it easier to work with a combination of several projects
# that need to be melted together.
#
# =Project files
# Project files represent the different project that needs to be build. Each project file contains the
# rules to build a single project. Additional projects can be included in the build process by using the
# \+import+ command.
#
# ==Isolation
# All definitions from the different project files are separated and contained in a separate project file
# namespace. By this the definitions contained in one project file do not disturb the definitions in other
# project files.
#
# ==Namespaces
# As all task and other build definitions are contained in a project file specific namespace they cannot simply
# be called from other project files. To access definitions from other project files one generally needs to address
# them by using the appropriate namespace.
# Namespaces in the context of the RakeBuilder tool are the relative paths between calling project file and called
# project file. For example take the following directory structure:
# - projectPath
#   - projectFile1
#   - subpath
#     - projectFile2
# If one wants to call tasks in projectFile2 from projectFile1 the appropriate namespace would be "subpath/projectFile2".
# This namespace is then combined with the task name of the task that one wants to call. If the task "task1" should be called
# in our example one would use the name "subpath/projectFile2:task1" to identify the task in projectFile1.
# This is done similarly for all objects that can be created through the RakeBuilder dsl.
#
# =Build process
# The build process of a RakeBuilder project hierarchy is based on a tree structure of information processing units the
# \+Processor+s. These processors are arbitrary units that can retreive input information and produce output
# information. The information transportet is a set of ruby objects that conform to the RakeBuilder \+InformationUnit+
# interface. This interface provides the means to the \+Processor+ to identify the given objects and decide
# whether it can process this type of information or not.
# With this system one can build arbitrary systems of processors that take in information specific to the build process
# and propagate it to the next build step.
# An example for this is the inclusion of a library into a project. The library specification is defined somewhere in the
# project file. A so called \#LibraryLocator# processor can then take this information and locate the library. The actual
# library instance is then given to another processor that for example defines the necessary tasks to build another library.
# The nice thing about the processor structure is that the processor for the library project can again be connected to another
# processor that builds an executable. This saves a lot of effort to redefine values of projects that are already given
# to build an existing project.