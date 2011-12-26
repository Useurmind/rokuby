# =Information Processing
# The RakeBuilder tool uses different pragmas for defining and creating build processes.
# A central part in this task is the definition of information that is processed to
# achieve a working build process.
#
# ==File Information
# Files are always dependend on the underlying system because each system uses a different
# harddisc. Therefore a build system must ensure the proper location and processing of all
# needed files in the build process.
# The RakeBuilder tool uses a two step process to describe a set of files.
#
# ===Specifications
# The first step is the specification of the files that should be used. Normally, this is done
# by defining regular expressions that can be used to locate the files needed in the build process.
# A collection of such regular expressions to specify a set of files is a so called InformationSpecification.
# There can be different types of specifications reaching from simple file set specifications to specifications
# of libaries and even complete projects (higher layers normally reuse the lower ones).
#
# ===Instances
# InformationInstances are the resulting product when looking up specifications on different systems.
# They contain detailed information about the files that were found on this specific system and can
# be used further up in the build process to execute steps that require this information.
#
# ===Processor
# The class that creates such instances is called a processor. Each specification type
# needs such a processor to find the information that is specified in it and create a
# corresponding instance that holds the information about the files that were found.
#
# ==Configuration Information
# Besides describing what (namely the files) should be build, one must describe how
# it should be build. The main part of this configuration information is contained in
# so called InformationConfiguration instances. They contain all information that is necessary
# to decide how the the files defined in the InformationInstances are to be put together.
# (This includes defines, binary type/name, platform, ...)
#
# ==Meta Information
# In some cases the above information is not enough to define a complete build process.
# In such cases additional meta information classes, normally called descriptions, can be
# used to define additional information that is needed to properly define the build process.
#
# ==Information Flow and Usage Patterns
# The most straightforward way to think of using this system is to define some specifications
# for the files used in the project and hand them over to a proper processor to take care of the work
# of building the project employing different configurations when doing this.
# But this is only a simple usecase. More complex usecases can be to define a series of specifications
# and reusing them in different projects by handing them to different processors. This reusability is
# one of the strong points present in this tool. Even large projects can be easily reused by handing their
# specification to a proper processor or inserting it into another specification.