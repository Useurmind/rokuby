# =Projects in the RakeBuilder tool
# The RakeBuilder tool provides the possibility to define projects that are then
# automatically build. It tries to lower the effort when managing project builds
# on different platforms. For this to happen it tries to provide a common structure
# for common parts on different platforms.

# ==Specifications
# Each project consists of the files that should be used, whatsoever the meaning of them.
# The means to specify the files in the RakeBuilder toolset is the so called
# InformationSpecification class. This class is a base class for specifying files that are
# required in the build process. Normally, such specifications consist of different
# regular expressions that depend on the type of files and their expected location on this
# platform.
#
# ==Instances
# The final location of the files and some additional information is saved in so called
# InformationInstances, which are then used to execute the build process.
#
# ==Processor
# The class that creates such instances is called a processor. Each specification type
# needs such a processor to find the information that is specified in it and create a
# corresponding instance that holds the information about the files that were found.